package cloudsmith

default match := false

# Minimum CVSS v3 score threshold
min_cvss_v3 := 7.0

match if count(reason) > 0

#
# Match normal scan vulnerabilities (non-OSV)
#
reason contains msg if {
    pkg := input.v0["package"]
    pkg.format == "docker"

    some target in input.v0.security_scan
    some vuln in target.Vulnerabilities  # Still present but considered legacy

    vuln.FixedVersion
    vuln.Status == "fixed"

    some _, sev in vuln.CVSS
    sev.V3Score >= min_cvss_v3

    msg := sprintf(
        "Standard scan vulnerability %s with CVSS v3 score %.1f (>= %.1f)",
        [vuln.ID, sev.V3Score, min_cvss_v3]
    )
}

#
# Match OSV SBOM vulnerabilities (preferred going forward)
#
reason contains msg if {
    pkg := input.v0["package"]
    pkg.format == "docker"

    some target in input.v0.security_scan
    some osv_vuln in target.OSVVulnerabilities

    some sev in osv_vuln.severity
    sev.type == "CVSS_V3"
    sev.numerical_score >= min_cvss_v3

    # Defensive check in case affected/package data is missing
    some affected in osv_vuln.affected
    some pkg_info in [affected.package]
    msg := sprintf(
        "OSV vulnerability %s with CVSS v3 score %.1f (>= %.1f) in SBOM component '%s' (%s)",
        [osv_vuln.id, sev.numerical_score, min_cvss_v3,
         pkg_info.name, pkg_info.ecosystem]
    )
}
