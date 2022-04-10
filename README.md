# Tralector

A feed reader that simply reads feeds.

This is a "100 year project". It should work in 100 years.

Read the accompanying article in 100-years.txt for more details.

## Usage

tralector is two parts: one part shell script, one part program code. The shell
script presents a nice user experience, while the program code handles the heavy
lifting.

Place urls, one per line, in `.tralector/urls`.

Run `tralector --help` to see option descriptions.

## Execution plan

tralector will read the list of URLs and fetch each one, one after the other. It
will keep track of the time it took so that it can be more concurrent on
subsequent runs. For example, if the first feed took 100 seconds to download,
and the second feed took 20 seconds to downloads, on the second run, it will see
that the first took more time than the second, and background the fetch, and
then start the second fetch.

Data is stored in a single file, .tralector/db, the format for each entry is:

<url>\n
<title>\n
<datetime>\n
<content>\n
\n

Due to the timing nature of feeds, and in an age with lots of memory, the file
should be entirely read into memory so that entries can be sorted and presented
in a chronological order.

As entries are read, it's up to the reading program to delete or modify the
db and rewrite it to file.

This file can be easily synced between other devices via a central server.

