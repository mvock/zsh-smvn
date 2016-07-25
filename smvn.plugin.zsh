function smvn {
    local usage="smvn: Search for JAR files on maven central

Syntax: smvn [files]

files is expected to be a list of files. If not provided, all files in the
current working directory are searched for.

Example: smvn lib/*RC*.jar
    (searches for all .jar files containing RC in their name)"

    if [[ -n "${*[(r)--help]}" ]]; then
        echo $usage
        return 1
    fi

    local filter='.docs[0] | "<dependency>\n<groupId>\(.g)</groupId>\n<artifactId>\(.a)</artifactId>\n<version>\(.v)</version>\n</dependency>\n"'
    sha1sum $* | while read -r; do
        read -r sum filename <<< "$REPLY"
        local url='http://search.maven.org/solrsearch/select?q=1:'$sum'&rows=20&wt=json'

        local json="$( curl -s -k "$url" | jq -r ".response | ( if ( .numFound == 0 ) then null else $filter end )" )"
        if [[ "$json" == "null" ]] ; then
            echo "Could not find $filename on maven central (SHA1 checksum: $sum)" >&2
        else
            echo $json
        fi
    done
}
