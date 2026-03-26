#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="${repo_root}/03.mapping/adrenal_selected_peak_inputs.tsv"
out_dir="${repo_root}/03.mapping"

mkdir -p "${out_dir}"

if ! command -v gzip >/dev/null 2>&1; then
  echo "gzip is required but not available." >&2
  exit 1
fi

if ! command -v awk >/dev/null 2>&1; then
  echo "awk is required but not available." >&2
  exit 1
fi

if ! command -v sort >/dev/null 2>&1; then
  echo "sort is required but not available." >&2
  exit 1
fi

tail -n +2 "${manifest}" | while IFS=$'\t' read -r species tissue selected_category selected_variant source_peak full_path source_link prepared_output; do
  if [[ ! -f "${full_path}" ]]; then
    echo "Missing source peak file: ${full_path}" >&2
    exit 1
  fi

  ln -sfn "${full_path}" "${source_link}"

  tmp_output="${prepared_output%.gz}"
  mkdir -p "$(dirname "${prepared_output}")"

  gzip -dc "${source_link}" \
    | awk -v species="${species}" -v tissue="${tissue}" -v category="${selected_category}" -v variant="${selected_variant}" 'BEGIN { OFS="\t" }
      {
        peak_id = species "_" tissue "_" category "_" variant "_peak_" sprintf("%07d", NR)
        name = ($4 == "." || $4 == "") ? peak_id : $4
        print $1, $2, $3, name, $5, $6, $7, $8, $9, $10
      }' \
    | LC_ALL=C sort -k1,1 -k2,2n -k3,3n \
    > "${tmp_output}"

  gzip -f "${tmp_output}"
  echo "Linked ${source_link} -> ${full_path}"
  echo "Prepared ${prepared_output}"
done
