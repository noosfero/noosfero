ls -1 *.rb | (
  i=1
  while read IN; do
    OUT=$(echo $IN | sed -e "s/^[0-9]\+/$(printf '%03d' $i)/")
    if [ "$IN" != "$OUT" ]; then
      echo mv $IN $OUT
    else
      echo "# $IN stays untouched"
    fi
    i=$[$i + 1]
  done
)
