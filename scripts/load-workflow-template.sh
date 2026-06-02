#!/bin/bash
# Workflow Template Loader
# Loads and applies workflow templates to customize feature development
# Usage: bash .claude/scripts/load-workflow-template.sh <template-name>

set -euo pipefail

# Get script directory and resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_ROOT="$(dirname "$SCRIPT_DIR")"

TEMPLATE_NAME="${1:-}"
TEMPLATE_DIR="$CLAUDE_ROOT/templates/workflows"
TEMPLATE_FILE="$TEMPLATE_DIR/$TEMPLATE_NAME.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display available templates
list_templates() {
  echo -e "${BLUE}Available Workflow Templates:${NC}"
  echo ""
  
  for template in "$TEMPLATE_DIR"/*.json; do
    if [ -f "$template" ]; then
      local name=$(basename "$template" .json)
      local desc=$(jq -r '.description' "$template" 2>/dev/null || echo "No description")
      local complexity=$(jq -r '.complexity' "$template" 2>/dev/null || echo "unknown")
      local time=$(jq -r '.estimated_time' "$template" 2>/dev/null || echo "unknown")
      
      echo -e "  ${GREEN}$name${NC}"
      echo -e "    Description: $desc"
      echo -e "    Complexity: $complexity | Time: $time"
      echo ""
    fi
  done
}

# Function to validate template
validate_template() {
  local template_file="$1"
  
  # Check if file exists
  if [ ! -f "$template_file" ]; then
    echo -e "${RED}Error: Template file not found: $template_file${NC}"
    return 1
  fi
  
  # Validate JSON syntax
  if ! jq empty "$template_file" 2>/dev/null; then
    echo -e "${RED}Error: Invalid JSON in template file${NC}"
    return 1
  fi
  
  # Check required fields
  local required_fields=("name" "description" "complexity" "phases")
  for field in "${required_fields[@]}"; do
    if ! jq -e ".$field" "$template_file" >/dev/null 2>&1; then
      echo -e "${RED}Error: Missing required field: $field${NC}"
      return 1
    fi
  done
  
  return 0
}

# Function to display template summary
display_template_summary() {
  local template_file="$1"
  
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}           WORKFLOW TEMPLATE LOADED${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
  echo ""
  
  local name=$(jq -r '.name' "$template_file")
  local desc=$(jq -r '.description' "$template_file")
  local complexity=$(jq -r '.complexity' "$template_file")
  local time=$(jq -r '.estimated_time' "$template_file")
  
  echo -e "${GREEN}Template:${NC} $name"
  echo -e "${GREEN}Description:${NC} $desc"
  echo -e "${GREEN}Complexity:${NC} $complexity"
  echo -e "${GREEN}Estimated Time:${NC} $time"
  echo ""
  
  # Display phase configuration
  echo -e "${BLUE}Phase Configuration:${NC}"
  
  local phases=$(jq -r '.phases | keys[]' "$template_file")
  while IFS= read -r phase; do
    local enabled=$(jq -r ".phases.\"$phase\".enabled" "$template_file")
    local duration=$(jq -r ".phases.\"$phase\".duration // \"N/A\"" "$template_file")
    local skip_reason=$(jq -r ".phases.\"$phase\".skip_reason // \"\"" "$template_file")
    
    if [ "$enabled" = "true" ]; then
      echo -e "  ${GREEN}✓${NC} $phase ($duration)"
    else
      echo -e "  ${YELLOW}⊘${NC} $phase (skipped: $skip_reason)"
    fi
  done <<< "$phases"
  echo ""
  
  # Display quality gates
  echo -e "${BLUE}Quality Gates:${NC}"
  local coverage=$(jq -r '.quality_gates.test_coverage // "N/A"' "$template_file")
  echo -e "  Test Coverage: $coverage"
  
  local test_count=$(jq -r '.quality_gates.required_tests | length' "$template_file" 2>/dev/null || echo "0")
  echo -e "  Required Tests: $test_count categories"
  
  local security_count=$(jq -r '.quality_gates.security_checks | length' "$template_file" 2>/dev/null || echo "0")
  echo -e "  Security Checks: $security_count checks"
  echo ""
  
  echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

# Function to export template configuration as environment variables
export_template_config() {
  local template_file="$1"
  
  # Export template metadata
  export WORKFLOW_TEMPLATE_NAME=$(jq -r '.name' "$template_file")
  export WORKFLOW_TEMPLATE_COMPLEXITY=$(jq -r '.complexity' "$template_file")
  export WORKFLOW_TEMPLATE_TIME=$(jq -r '.estimated_time' "$template_file")
  
  # Export phase configuration
  local phases=$(jq -r '.phases | keys[]' "$template_file")
  while IFS= read -r phase; do
    local phase_var=$(echo "$phase" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
    local enabled=$(jq -r ".phases.\"$phase\".enabled" "$template_file")
    local duration=$(jq -r ".phases.\"$phase\".duration // \"\"" "$template_file")
    
    export "WORKFLOW_${phase_var}_ENABLED=$enabled"
    export "WORKFLOW_${phase_var}_DURATION=$duration"
  done <<< "$phases"
  
  # Export quality gates
  export WORKFLOW_TEST_COVERAGE=$(jq -r '.quality_gates.test_coverage // "80%"' "$template_file")
  
  echo -e "${GREEN}✓ Template configuration exported to environment${NC}"
}

# Main execution
main() {
  # If no template name provided, list available templates
  if [ -z "$TEMPLATE_NAME" ]; then
    list_templates
    exit 0
  fi
  
  # Validate template
  if ! validate_template "$TEMPLATE_FILE"; then
    echo ""
    echo -e "${YELLOW}Available templates:${NC}"
    list_templates
    exit 1
  fi
  
  # Display template summary
  display_template_summary "$TEMPLATE_FILE"
  
  # Export configuration
  export_template_config "$TEMPLATE_FILE"
  
  # Save template path for workflow to use
  mkdir -p "$CLAUDE_ROOT"
  echo "$TEMPLATE_FILE" > "$CLAUDE_ROOT/.current-template"
  
  echo -e "${GREEN}✓ Template loaded successfully${NC}"
  echo -e "${BLUE}Workflow will use this template configuration${NC}"
}

main
