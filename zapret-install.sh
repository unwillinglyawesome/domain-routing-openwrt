install_zapret() {
    ZAPRET_URL="https://github.com/bol-van/zapret/releases/download/v71.4/zapret-v71.4-openwrt-embedded.tar.gz"
    TOP_FOLDER="zapret-v71.4"

    wget "$ZAPRET_URL" -O /tmp/zapret.tar.gz
    tar -xzf /tmp/zapret.tar.gz -C /tmp/
    chmod +x /tmp/"$TOP_FOLDER"/*.sh
    if /tmp/"$TOP_FOLDER"/install_easy.sh; then
        cat > /opt/zapret/config << 'EOF'
FWTYPE=nftables

SET_MAXELEM=522288
IPSET_OPT="hashsize 262144 maxelem $SET_MAXELEM"

IP2NET_OPT4="--prefix-length=22-30 --v4-threshold=3/4"
IP2NET_OPT6="--prefix-length=56-64 --v6-threshold=5"
AUTOHOSTLIST_RETRANS_THRESHOLD=3
AUTOHOSTLIST_FAIL_THRESHOLD=3
AUTOHOSTLIST_FAIL_TIME=60
AUTOHOSTLIST_DEBUGLOG=0

MDIG_THREADS=30

GZIP_LISTS=1

DESYNC_MARK=0x40000000
DESYNC_MARK_POSTNAT=0x20000000

NFQWS_ENABLE=1
NFQWS_PORTS_TCP=443
NFQWS_PORTS_UDP=50000-50100
NFQWS_TCP_PKT_OUT=$((6+$AUTOHOSTLIST_RETRANS_THRESHOLD))
NFQWS_TCP_PKT_IN=3
NFQWS_UDP_PKT_OUT=$((6+$AUTOHOSTLIST_RETRANS_THRESHOLD))
NFQWS_UDP_PKT_IN=0
NFQWS_OPT="
--filter-udp=50000-50100 --filter-l7=discord,stun --dpi-desync=fake --dpi-desync-repeats=6 --new
--filter-tcp=443 --dpi-desync=split2 --dpi-desync-repeats=2 --dpi-desync-split-seqovl=681 --dpi-desync-split-pos=1 --dpi-desync-fooling=badseq --dpi-desync-split-seqovl-pattern="/opt/zapret/files/fake/tls_clienthello_www_google_com.bin" --hostlist=/tmp/zapret.lst
"

MODE_FILTER=none

FLOWOFFLOAD=donttouch

INIT_APPLY_FW=1

DISABLE_IPV6=1

FILTER_TTL_EXPIRED_ICMP=1
EOF
    else
        echo "Error: install_easy.sh failed"
        exit 1
    fi
}

install_zapret
