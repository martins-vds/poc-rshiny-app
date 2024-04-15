#!/bin/bash

set -e
set -o pipefail

function display_usage() {
        echo "Usage: $0 --acr-name <acr_name> --docker-file <docker_file> --docker-directory <docker_directory> --image-name-prefix <image_name_prefix> --image-name <image_name> --version-file <version_file>"
}

function main() {        
        local acr_name=""
        local docker_file=""
        local docker_directory=""
        local image_name_prefix=""
        local image_name=""
        local version_file=""

        while [[ $# -gt 0 ]]; do
                case "$1" in
                --acr-name)
                        acr_name=$2
                        shift 2
                        ;;
                --docker-file)
                        docker_file=$2
                        shift 2
                        ;;
                --docker-directory)
                        docker_directory=$2
                        shift 2
                        ;;
                --image-name-prefix)
                        image_name_prefix=$2
                        shift 2
                        ;;
                --image-name)
                        image_name=$2
                        shift 2
                        ;;
                --version-file)
                        version_file=$2
                        shift 2
                        ;;
                *)
                        echo "Invalid option: $1."
                        display_usage
                        exit 2
                        ;;
                esac
        done

        version_line=$(cat "${version_file}")
        # shellcheck disable=SC2206
        version_array=(${version_line//=/ })
        version="${version_array[1]//\"/}"

        az acr login --name "${acr_name}"

        acr_domain_suffix=$(az cloud show --query suffixes.acrLoginServerEndpoint --output tsv)
        acr_fqdn="${acr_name}${acr_domain_suffix}"
        full_image_name_prefix=${acr_fqdn}/${image_name_prefix}

        docker build -t "${full_image_name_prefix}/${image_name}:${version}" -f "$docker_file" "$docker_directory"
        docker push "${full_image_name_prefix}/${image_name}:${version}"
}

main "$@"
