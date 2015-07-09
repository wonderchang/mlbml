require! <[fs tabletojson]>

mlb-host = \http://mlb.mlb.com
src-dir = \src/games
res-dir = \res/games
if !fs.exists-sync res-dir then fs.mkdir-sync res-dir

for date in (fs.readdir-sync src-dir)
  if !fs.exists-sync "#res-dir/#date"
    fs.mkdir-sync "#res-dir/#date"
  for game in (fs.readdir-sync "#src-dir/#date")
    o = gameinfo: {}, score: {}, record: away: {}, home: {}
    d = fs.read-file-sync "#src-dir/#date/#game", \utf-8
    if d is /<h2 style="margin-top:10px;">(.*?)<\/h2>/
      result = (that.1 / ', ').map -> it = it / ' '; team: it.0, score: parseInt it.1
      o.score.win = result.0; o.score.lose = result.1
    if d is /(<table class="lineScore mlbBoxScore postEvent">.*?<\/table>)/
      o.score.detail = tabletojson.convert that.1
    o.summery = {}
    if d is /<td.*?class="playAlerts"><div class="mTop10"><b>(.*?)<\/div>/
      arr = (that.1 / '<b>').map -> it / ':<\/b> '
      for a in arr then o.summery[a.0] = a.1.trim!
    if d is /<\/div><div class="mTop10"><div class="mTop5"><b>(.*?)<\/div>/
      o.summery.hr = that.1
    if d is /(<table class="data" width="100%" ><tr class="away">.*?Hitters.*?<\/table>)/
      table = (tabletojson.convert that.1).0
      o.record.away.team = table.shift!.0
      o.record.away.hit = parse-table table
    if d is /(<table class="data" width="100%" ><tr class="home">.*?Hitters.*?<\/table>)/
      table = (tabletojson.convert that.1).0
      o.record.home.team = table.shift!.0
      o.record.home.hit = parse-table table
    if d is /(<table class="data" width="100%" ><tr class="away">.*?Pitchers.*?<\/table>)/
      table = (tabletojson.convert that.1).0
      o.record.away.team = table.shift!.0
      o.record.away.pitch = parse-table table
    if d is /(<table class="data" width="100%" ><tr class="home">.*?Pitchers.*?<\/table>)/
      table = (tabletojson.convert that.1).0
      o.record.home.team = table.shift!.0
      o.record.home.pitch = parse-table table
    if d is /(<table class="data" width="100%" ><tr class="home"><td colspan="1">Game Information.*?<\/table>)/
      table = (tabletojson.convert that.1).0; table.shift!
      for row in table
        arr = row.0 / ' - '
        o.gameinfo[arr.shift!.replace ' ', ''] = arr * ' - '
    fs.write-file-sync "#res-dir/#date/#game.json", JSON.stringify o, null, '\t'
    console.log "#res-dir/#date/#game.json saved."

function parse-table table
  act = comment: [], players: []
  while (Object.keys table[table.length - 1]).length is 1 then act.comment.push table.pop!.0
  field = table.shift!
  for row in table
    hitter = {}
    for i in Object.keys row then hitter[field[i]] = row[i]
    act.players.push hitter
  act

