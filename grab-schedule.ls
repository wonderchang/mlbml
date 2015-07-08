require! <[fs phantom moment]>

url = "http://mlb.mlb.com/mlb/schedule/index.jsp\#date="
user-agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36"
out-dir = \src/schedule

time = moment process.argv.2
file = time.format 'YYYY-MM-DD'
date = time.format 'MM/DD/YYYY'
phantom.create (ph) ->
  ph.create-page (page) ->
    page.set \setting, user-agent: user-agent
    file := out-dir+'/'+file
    if fs.exists-sync file then return console.log file+' have already saved (Skip)'
    page.open url+date, ->
      page.get-content (content) ->
        if content is /<div id=\"scheduleContainer\">(<div style=\"\"><h2 class=\"scheduleDate\">.*)<\/div>/
          arr = that.1.split '<div style="">'
          fs.write-file-sync file, arr.1
          console.log file+' saved'
        ph.exit!
