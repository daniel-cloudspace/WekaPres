

function get_cnn_csv() {
  echo '"cnn_news_story_for_'$1'"' > cnn_news_stories_for_$1.csv
  for start in `seq 0 5`; do 
    echo
    echo "Pulling urls from: http://newspulse.cnn.com/filter?count=20&filters=topic%3A$1%2C&range=fifteen&start=$start&keywords=&ROOT="
    echo
  
    wget -U firefox "http://newspulse.cnn.com/filter?count=20&filters=topic%3A$1%2C&range=fifteen&start=$start&keywords=&ROOT=" -qO - | grep 'FULL STORY' | grep -oE 'http://[^"]*'|sort -u | while read story_url; do 
      echo "$story_url" >&2
      wget -U firefox "$story_url" -qO - | grep "cnn_strybtntoolsbttm" | sed 's/<script.*<\/script>/ /g; s/&[0-9a-zA-Z]*;/ /g; s/<[^>]*>/ /g;' | tr A-Z a-z > storytext.txt
      if [ "`cat storytext.txt | wc -l`" != "0" ]; then
        cat storytext.txt | tr "\n" ' ' | sed 's/"/ /g; s/  */ /g'
      fi
    done | sed 's/^ *//; s/^/"/; s/$/"/;' | grep -v '^""$' >> cnn_news_stories_for_$1.csv
  done
}


for i in crime health living money opinion politics rireport showbiz tech  travel us world; do
  echo "###### Pulling dataset for $i ###########"
  echo
  get_cnn_csv $i
done

echo '"cnn_news_story_for_'$1'"' > cnn_news_stories_for_all.csv
cat cnn_news_stories_for_*.csv | grep -v '"cnn_news_story_for_'$1'"' >> cnn_news_stories_for_all.csv
