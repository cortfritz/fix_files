# FixFiles

FixFiles is an elixir app designed for a one-time use to convert a large (roughly 10TB and 1M files) local store to be compliant with egnyte storage.

Requirements:
1. Fix both filenames and directories
2. Convert any instance of the characters \  /  "   :  < >  |  *  ? with a hyphen.
3. Trim leading or trailing spaces
4. When fixing a file or directory name causes it to collide with an existing name, append -DUP-NNNN where NNNN is a four character random string drawn from the letters A-Z and number 0-9.
5. create a text change log 
6. has to be robust:
  - don't mess up the files!
  - don't miss anything!
  - work well so that i don't have to baby the script, probably specifically work over enormous directory trees.  i.e. don't run out of memory.

## Installation

1. clone this repo
2. install elixir (i'm runnign 1.14.2 w/ erlang 25.1)
3. mix compile
4. iex -S mix
5. from iex, FixFiles.list_all("your/relative/or/absolute/directory")

That's it!