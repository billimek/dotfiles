# copies PCF env to local env!
function cf-copy-env () {
  [[ -z "$1" ]] && return 1;
  APP_GUID=$(cf app "${1}" --guid) || return 1;
  JSON_ENV="$(cf curl /v2/apps/${APP_GUID}/env)"
  export VCAP_SERVICES="$(jq '.system_env_json.VCAP_SERVICES' <<<" ${JSON_ENV}");"
  export VCAP_APPLICATION="$(jq '.application_env_json.VCAP_APPLICATION' <<< "${JSON_ENV}");"
  eval "$(
    jq -r '.environment_json as $env
      | $env
      | keys
      | map("export \(.)=" + ($env[.] | @json))
      | .[]' <<< "${JSON_ENV}"
  )"
}


function cf-get-info () {
  # get cloudfoundry info
  if [[ -f ~/.cf/config.json ]]; then
    cf_foundation=$(grep ".Target" ~/.cf/config.json | sed -E 's/.*api.*run[.-]?(.*)\.homedepot\.com.*/\1/')
    if [[ -n "$cf_foundation" ]]; then
      # if we have the jq bin, grab the org and space info, if we're logged in to cf
      local jq_bin=$(command -v jq 2> /dev/null)
      if [[ -n "$jq_bin" ]]; then
        local cf_org=$("${jq_bin}" -r .OrganizationFields.Name ~/.cf/config.json 2>/dev/null)
        local cf_space=$("${jq_bin}" -r .SpaceFields.Name ~/.cf/config.json 2>/dev/null)
      fi
      if [[ -n "$cf_org" && -n "$cf_space" ]]; then
        local cf_foundation_string="${cf_foundation}/${cf_org}/${cf_space}"
      else
        local cf_foundation_string="${cf_foundation}"
      fi
      [[ $cf_foundation == at ]] && echo -n "☁️  ${cf_foundation_string}" # sandbox
      [[ $cf_foundation =~ np ]] && echo -n "☁️  ${cf_foundation_string}" # non-prod
      [[ $cf_foundation =~ .*z[a-z].* ]] && echo -n "☁️  ⚠️  ${cf_foundation_string} ⚠️" # production
    fi
  fi
}
