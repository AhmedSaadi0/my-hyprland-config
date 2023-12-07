if [[ "$(locale | grep -oP 'LANG=\K\w+')" == *ar* ]]; then
    echo "RTL"
else
    echo "LTR"
fi
