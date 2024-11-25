#!/bin/bash

valid_ip() {
    local ip="$1"
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

check_ip() {
    local host="$1"
    local ip="$2"
    local dns_server="$3"

    if ! valid_ip "$ip"; then
        echo "Adresa IP '$ip' nu este validă."
        return 1
    fi

    resolved_ip=$(dig @$dns_server +short "$host")

    if [[ -z "$resolved_ip" ]]; then
        echo "Nu am putut rezolva adresa IP pentru hostul '$host' folosind serverul DNS '$dns_server'."
        return 1
    fi

    if [[ "$resolved_ip" == "$ip" ]]; then
        return 0
    else
        echo "Adresa IP '$ip' NU este asociată cu hostul '$host' (rezolvată: '$resolved_ip')."
        return 1
    fi
}

cat /etc/hosts | while read ip dom
do
    if [[ "$ip" == "#" ]] || [[ -z "$ip" ]]; then
        continue
    fi

    if [[ "$dom" == "localhost" || "$dom" == "$(hostname)" ]]; then
        continue
    fi

    check_ip "$dom" "$ip" "8.8.8.8"
    
    if [[ $? -ne 0 ]]; then
        echo "Bogus IP for $dom in /etc/hosts"
    fi
done

exit 0

