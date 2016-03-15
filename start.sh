#!/bin/sh

./activator dist
cd target/universal/
rm -rf play24-slick30-play2-auth-mysql-1_0_0
unzip play24-slick30-play2-auth-mysql-1_0_0.zip

#./play24-slick3.0-play2-auth-mysql/bin/play24-slick3-auth-example

ACTIVATOR=./play24-slick30-play2-auth-mysql-1_0_0/bin/play24-slick30-play2-auth-mysql

# Export the keystore password for use in ws.conf
export KEY_PASSWORD=`cat play24-slick30-play2-auth-mysql-1_0_0/conf/certs/password`

# Turn on HTTPS, turn off HTTP.
# This should be https://example.com:9443
JVM_OPTIONS="$JVM_OPTIONS -Dhttp.port=disabled"
JVM_OPTIONS="$JVM_OPTIONS -Dhttps.port=9443"

# Note that using the HTTPS port by itself doesn't set rh.secure=true.
# rh.secure will only return true if the "X-Forwarded-Proto" header is set, and
# if the value in that header is "https", if either the local address is 127.0.0.1, or if
# trustxforwarded is configured to be true in the application configuration file.

# Define the SSLEngineProvider in our own class.
JVM_OPTIONS="$JVM_OPTIONS -Dplay.http.sslengineprovider=https.CustomSSLEngineProvider"

# Enable this if you want to turn on client authentication
#JVM_OPTIONS="$JVM_OPTIONS -Dplay.ssl.needClientAuth=true"

# Enable the handshake parameter to be extended for better protection.
# http://docs.oracle.com/javase/8/docs/technotes/guides/security/jsse/JSSERefGuide.html#customizing_dh_keys
# Only relevant for "DHE_RSA", "DHE_DSS", "DH_ANON" algorithms, in ServerHandshaker.java.
JVM_OPTIONS="$JVM_OPTIONS -Djdk.tls.ephemeralDHKeySize=2048"

# Don't allow client to dictate terms - this can also be used for DoS attacks.
# Undocumented, defined in sun.security.ssl.Handshaker.java:205
JVM_OPTIONS="$JVM_OPTIONS -Djdk.tls.rejectClientInitiatedRenegotiation=true"

# Add more details to the disabled algorithms list
# http://docs.oracle.com/javase/8/docs/technotes/guides/security/jsse/JSSERefGuide.html#DisabledAlgorithms
# and http://bugs.java.com/bugdatabase/view_bug.do?bug_id=7133344
JVM_OPTIONS="$JVM_OPTIONS -Djava.security.properties=disabledAlgorithms.properties"

# Fix a version number problem in SSLv3 and TLS version 1.0.
# http://docs.oracle.com/javase/7/docs/technotes/guides/security/SunProviders.html
JVM_OPTIONS="$JVM_OPTIONS -Dcom.sun.net.ssl.rsaPreMasterSecretFix=true"

# Tighten the TLS negotiation issue.
# http://docs.oracle.com/javase/8/docs/technotes/guides/security/jsse/JSSERefGuide.html#descPhase2
# Defined in JDK 1.8 sun.security.ssl.Handshaker.java:194
JVM_OPTIONS="$JVM_OPTIONS -Dsun.security.ssl.allowUnsafeRenegotiation=false"
JVM_OPTIONS="$JVM_OPTIONS -Dsun.security.ssl.allowLegacyHelloMessages=false"

# Enable this if you need to use OCSP or CRL
# http://docs.oracle.com/javase/8/docs/technotes/guides/security/certpath/CertPathProgGuide.html#AppC
#JVM_OPTIONS="$JVM_OPTIONS -Dcom.sun.security.enableCRLDP=true"
#JVM_OPTIONS="$JVM_OPTIONS -Dcom.sun.net.ssl.checkRevocation=true"

# Enable this if you need TLS debugging
# http://docs.oracle.com/javase/8/docs/technotes/guides/security/jsse/JSSERefGuide.html#Debug
#JVM_OPTIONS="$JVM_OPTIONS -Djavax.net.debug=ssl:handshake"

# Change this if you need X.509 certificate debugging
# http://docs.oracle.com/javase/8/docs/technotes/guides/security/troubleshooting-security.html
#JVM_OPTIONS="$JVM_OPTIONS -Djava.security.debug=certpath:x509:ocsp"

# Run Play
$ACTIVATOR $JVM_OPTIONS $*;
