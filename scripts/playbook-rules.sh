#!/bin/bash
set -e

# Target directory is the first argument, or current directory
TARGET_DIR=${1:-"."}
cd "$TARGET_DIR"

echo "=== Applying Custom Playbook Rules ==="

# 1. Testing: Replace Mockito Annotations (Section 8 of Playbook)
echo "Updating Testing annotations..."
grep -r "@MockBean" src/ --include="*.java" | xargs -r sed -i 's/@MockBean/@MockitoBean/g'
grep -r "@SpyBean" src/ --include="*.java" | xargs -r sed -i 's/@SpyBean/@MockitoSpyBean/g'
sed -i 's/import org.springframework.boot.test.mock.mockito.MockBean;/import org.springframework.test.context.bean.override.mockito.MockitoBean;/g' src/**/*.java 2>/dev/null || true
sed -i 's/import org.springframework.boot.test.mock.mockito.SpyBean;/import org.springframework.test.context.bean.override.mockito.MockitoSpyBean;/g' src/**/*.java 2>/dev/null || true

# 2. Jackson: Migrate to Jakarta Namespace (Section 5 of Playbook)
echo "Updating Jackson properties..."
find src/main/resources -name "application.properties" -exec sed -i 's/spring.jackson.read./spring.jackson.json.read./g' {} +
find src/main/resources -name "application.yml" -exec sed -i 's/read:/json:\n        read:/g' {} +

# 3. Security: Basic Lambda DSL cleanup (Section 6 of Playbook)
echo "Checking for Security Filter Chain patterns..."
# This is a 'soft' fix for the most common .and() removal
grep -r ".and()" src/ --include="*SecurityConfig.java" | xargs -r sed -i 's/.and()//g'

# 4. Cleanup: Remove Undertow if found (Section 4 of Playbook)
echo "Removing Undertow exclusions (SB4 default is Tomcat/Jetty)..."
sed -i '/<artifactId>spring-boot-starter-undertow<\/artifactId>/d' pom.xml

echo "=== Custom Rules Applied Successfully ==="