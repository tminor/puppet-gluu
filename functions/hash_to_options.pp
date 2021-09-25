function gluu::hash_to_options(Hash $hash) {
  $hash.reduce('') |$memo, $kv| {
    $key = regsubst($kv[0], '_', '-')
    $value = $kv[1]
    join([$memo, "-${key}", "\"${value}\""], ' ')
  }
}
