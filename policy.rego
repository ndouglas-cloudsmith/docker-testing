package cloudsmith

default match := false

# Minimum CVSS v3 score threshold
min_cvss_v3 := 7.0

match if count(reason) > 0

reason contains msg if {
    # Limit to Docker packages
    pkg := input.v0["package"]
    pkg.format == "docker"

    # Iterate over security scan results
    some target in input.v0.security_scan
    some osv_vuln in target.OSVVulnerabilities

    # Ensure we have severity data
    some sev in osv_vuln.severity
    sev.type == "CVSS_V3"
    sev.numerical_score >= min_cvss_v3

    # Build message from OSV vulnerability ID and score
    msg := sprintf(
        "OSV vulnerability %s with CVSS v3 score %.1f (>= %.1f) found in SBOM component '%s' (%s)",
        [osv_vuln.id, sev.numerical_score, min_cvss_v3, osv_vuln.affected[0].package.name, osv_vuln.affected[0].package.ecosystem]
    )
}
