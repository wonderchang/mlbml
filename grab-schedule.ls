require! <[fs phantom moment]>

time = moment \2015-04-05
now = moment!

url = "http://mlb.mlb.com/mlb/schedule/index.jsp\#date="
user-agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36"
out-dir = \src
if !fs.exists-sync out-dir then fs.mkdir-sync out-dir
out-dir += \/schedule
if !fs.exists-sync out-dir then fs.mkdir-sync out-dir

time-list = []

while time.unix! <= now.unix!
  time-list.push do
    file: time.format 'YYYY-MM-DD'
    date: time.format 'MM/DD/YYYY'
  time.add 1, \d

time-list.for-each (e) ->
  e.file = out-dir+'/'+e.file
  if fs.exists-sync e.file
    return console.log e.file+' have already saved (Skip)'
  phantom.create (ph) ->
    ph.create-page (page) ->
      page.set \setting, user-agent: user-agent
      page.open url+e.date, ->
        page.get-content (content) ->
          if content is /<div id=\"scheduleContainer\">(<div style=\"\"><h2 class=\"scheduleDate\">.*)<\/div>/
            arr = that.1.split '<div style="">'
            fs.write-file-sync e.file, arr.1
            console.log e.file+' saved'
          ph.exit!



