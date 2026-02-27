package tree_sitter_cm_test

import (
	"testing"

	tree_sitter "github.com/tree-sitter/go-tree-sitter"
	tree_sitter_cm "github.com/tree-sitter/tree-sitter-cm/bindings/go"
)

func TestCanLoadGrammar(t *testing.T) {
	language := tree_sitter.NewLanguage(tree_sitter_cm.Language())
	if language == nil {
		t.Errorf("Error loading C(m) grammar")
	}
}
