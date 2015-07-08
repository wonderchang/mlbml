require! <[fs tabletojson]>

mlb-host = \http://mlb.mlb.com
src-dir = \src/schedule
res-dir = \res
if !fs.exists-sync res-dir then fs.mkdir-sync res-dir


output = []; wget = []
wget.push 'if ! [ -d "src/games" ]'
wget.push 'then'
wget.push '\tmkdir src/games'
wget.push 'fi'
for date in (fs.readdir-sync src-dir)
  console.log date
  wget.push 'if ! [ -d "src/games/'+date+'" ]'
  wget.push 'then'
  wget.push "\tmkdir src/games/#date"
  wget.push 'fi'
  obj = date: date, games: []
  d = fs.read-file-sync "#src-dir/#date", \utf-8
  if d is /(<table.*border="0">.*<\/table>)/ then d = that.1
  if d is /<tbody>(.*)<\/tbody>/ then d = that.1
  d = d.split /<tr class=".*?">/; d.shift!
  for row in d
    game = away: {}, home: {}, result: {}
    if row is /away_full"><a href=".*?">(.*?)<\/a><\/td>/ then game.away.team = that.1
    if row is /away_full"><a href="(.*?)">.*?<\/a><\/td>/ then game.away.href = mlb-host+that.1
    if row is /away_full"><a href="\/index\.jsp\?c_id=(\w+)">.*?<\/a><\/td>/
      game.away.city = switch that.1
      | \cws      => \chw
      | otherwise => that.1
    if row is /home_full"><a href=".*?">(.*?)<\/a><\/td>/ then game.home.team = that.1
    if row is /home_full"><a href="(.*?)">.*?<\/a><\/td>/ then game.home.href = mlb-host+that.1
    if row is /home_full"><a href="\/index\.jsp\?c_id=(\w+)">.*?<\/a><\/td>/
      game.home.city = switch that.1
      | \cws      => \chw
      | otherwise => that.1
    if row is /time_result"><a href=".*?" title="">(.*?)<\/a><\/td>/ then game.result.score = that.1
    game.result.href = "http://www.cbssports.com/mlb/gametracker/boxscore/MLB_#{date / '-' * ''}_#{game.away.city.to-upper-case!}@#{game.home.city.to-upper-case!}"
    console.log '\t'+game.away.team+' v.s. '+game.home.team
    obj.games.push game
    away = game.away.team / ' ' * ''
    home = game.home.team / ' ' * ''
    wget.push 'if ! [ -f "src/games/'+"#date/#{away}-#{home}"+'" ]'
    wget.push 'then'
    wget.push "\twget -O src/games/#date/#{away}-#{home} #{game.result.href}"
    wget.push 'fi'
  output.push obj

fs.write-file-sync "#res-dir/schedule.json", JSON.stringify output, null, '\t'
fs.write-file-sync "grab-game.sh", (wget * '\n')
fs.chmod-sync "grab-game.sh", "0755"
