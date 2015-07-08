require! <[fs moment]>

time = moment \2015-04-05
now = moment!

time-list = []
cmd = ["mkdir -p res src src/schedule"]

while time.unix! <= now.unix!
  date = time.format 'YYYY-MM-DD'
  cmd.push "lsc grab-schedule.ls #date"
  time.add 1, \d

fs.write-file-sync "grab-schedule.sh", (cmd.join '\n')
fs.chmod-sync "grab-schedule.sh", \0755
