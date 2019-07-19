#!/bin/bash

rm -rf output
mkdir output

document_name=index.html

cat >"$document_name" <<EOF
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>KAG Heads Judging Page</title>
	<link rel="stylesheet" type="text/css" href="style.css">
	<script src="script.js"></script>
</head>
<body>
<div id="container">
EOF

for d in entries/* ; do
	dirname=${d:8}
	dirlen=${#d}+1
	echo "$dirname"
	for f in "$d"/* ; do
		fname=${f:$dirlen}
		_without_extension=${#fname}-4
		fname=${fname:0:$_without_extension}

		id="$dirname"_"$fname"
		out_name="output/$id.png"

		#render image (background process)
		love .. "heads_contest/$f" "$out_name" &

		#add to html
		cat >>"$document_name" <<EOF
	<div class="entry">
		<img src="$out_name"></img>
		<div class="rating">
			<input type="range" name="$id" min="1" max="5" value="3" step="1">
		</div>
	</div>
EOF
	done ;
	#wait on the renders
	wait
done

cat >>"$document_name" <<EOF 
	<input type="button" id="rate_button" value="done rating!">
	<br>
	<textarea id="rate_outcome" width="800px"></textarea>
</div>
</body>
</html>
EOF