package cloudsmith
default match := false
match if count(reason) > 0

#
# Log all legacy vulnerabilities
#
reason[msg] if {
    pkg := input.v0["package"]
    some target in input.v0.security_scan
    some vuln in target.Vulnerabilities
    msg := sprintf("[LEGACY] ID=%s Status=%s FixedVersion=%s CVSS=%v", 
        [vuln.ID, vuln.Status, vuln.FixedVersion, vuln.CVSS])
}

#
# Log all OSV vulnerabilities
#
reason[msg] if {
    pkg := input.v0["package"]
    some target in input.v0.security_scan
    some osv_vuln in target.OSVVulnerabilities
    msg := sprintf("[OSV] ID=%s Severity=%v Affected=%v", 
        [osv_vuln.id, osv_vuln.severity, osv_vuln.affected])
}

#
# Log full security_scan object for raw inspection
#
reason[msg] if {
    msg := sprintf("[DEBUG] security_scan: %v", [input.v0.security_scan])
}
