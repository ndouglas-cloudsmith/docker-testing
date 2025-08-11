package cloudsmith
default match := false
match if count(reason) > 0

reason contains msg if {
  some vuln in input.v0.security_scan_osv.Vulnerabilities
  msg := sprintf(
    "OSV ID: %s | Ecosystem: %s | Package: %s | Severities: %v",
    [
      vuln.id,
      vuln.affected[0].package.ecosystem,
      vuln.affected[0].package.name,
      vuln.affected[0].severity
    ]
  )
}
