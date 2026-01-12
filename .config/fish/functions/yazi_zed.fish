function yazi_zed
    set -l tmp (mktemp -t "yazi-chooser.XXXXX")
    yazi $argv --chooser-file="$tmp"
    set -l opened_file (head -n 1 "$tmp")

    zed -- "$opened_file"
    rm -f -- "$tmp"
end
