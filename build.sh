#! /bin/bash

xfbuild \
+xcore +xstd +xetc \
+xatk +xcairo +xgdk +xgdkpixbuf +xgio +xglib +xgtk +xpango +xgobject +xgtkc +xgthread  \
+full +redeps \
-O -inline -release \
-L-lgtkd -L-lespeak \
$@ gui.d \
+o=ipats
