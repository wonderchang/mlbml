require! <[fs tabletojson]>

mlb-host = \http://mlb.mlb.com
src-dir = \src/games
res-dir = \res/games
if !fs.exists-sync res-dir then fs.mkdir-sync res-dir

for date in [(fs.readdir-sync src-dir).0] then
  if !fs.exists-sync "#src-dir/#date"
    fs.mkdir-sync "#src-dir/#date"
  for game in (fs.readdir-sync "#src-dir/#date")
    o = score: {}
    d = fs.read-file-sync "#src-dir/#date/#game", \utf-8
    if d is /<h2 style="margin-top:10px;">(.*?)<\/h2>/
      result = (that.1 / ', ').map -> it = it / ' '; team: it.0, score: parseInt it.1
      o.score.win = result.0; o.score.lose = result.1
