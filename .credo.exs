# This file contains the configuration for Credo
%{
  #
  # You can have as many configs as you want in the `configs:` field.
  configs: [
    %{
      #
      # Run any exec using `mix credo -C <name>`. If no name is given
      # ":default" is used.
      #
      name: "default",
      #
      # These are the files included in the analysis:
      files: %{
        #
        # You can give explicit globs or simply remove the entry.
        # Credo will check all files ending in `.ex` or `.exs` in the
        # `lib` and `test` directories.
        #
        included: ["lib/", "test/", "config/"],
        excluded: [
          ~r"/_build/",
          ~r"/deps/",
          ~r"/node_modules/",
          ~r"/priv/repo/migrations/"
        ]
      },
      #
      # If you create your own checks, you must specify them here.
      #
      checks: [
        #
        ## Consistency Checks
        #
        {Credo.Check.Consistency.ExceptionNames},
        {Credo.Check.Consistency.LineEndings},
        {Credo.Check.Consistency.ParameterPatternMatching},
        {Credo.Check.Consistency.SpaceAroundOperators},
        {Credo.Check.Consistency.SpaceInParentheses},
        {Credo.Check.Consistency.TabsOrSpaces},

        ## Design Checks
        #
        # You can customize the priority of any check.
        # Priority values are: `low, normal, high, higher`
        #
        {Credo.Check.Design.AliasUsage,
         [
           priority: :low,
           if_nested_deeper_than: 2,
           if_called_more_often_than: 0
         ]},
        {Credo.Check.Design.TagFIXME, false},
        {Credo.Check.Design.TagTODO, exit_status: 0},

        ## Readability Checks
        #
        {Credo.Check.Readability.AliasOrder},
        {Credo.Check.Readability.FunctionNames},
        {Credo.Check.Readability.LargeNumbers},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Readability.ModuleAttributeNames},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.ModuleNames},
        {Credo.Check.Readability.ParenthesesInCondition},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs},
        {Credo.Check.Readability.PredicateFunctionNames},
        {Credo.Check.Readability.PreferImplicitTry},
        {Credo.Check.Readability.RedundantBlankLines},
        {Credo.Check.Readability.Semicolons},
        {Credo.Check.Readability.SpaceAfterCommas},
        {Credo.Check.Readability.StringSigils},
        {Credo.Check.Readability.TrailingBlankLine},
        {Credo.Check.Readability.TrailingWhiteSpace},
        {Credo.Check.Readability.UnnecessaryAliasExpansion},
        {Credo.Check.Readability.VariableNames},
        {Credo.Check.Readability.WithSingleClause, false},

        ## Refactoring Opportunities
        #
        {Credo.Check.Refactor.ABCSize, false},
        {Credo.Check.Refactor.AppendSingleItem, false},
        {Credo.Check.Refactor.CondStatements},
        {Credo.Check.Refactor.CyclomaticComplexity, false},
        {Credo.Check.Refactor.DoubleBooleanNegation},
        {Credo.Check.Refactor.FilterFilter},
        {Credo.Check.Refactor.FilterReject},
        {Credo.Check.Refactor.FunctionArity},
        {Credo.Check.Refactor.IoPuts},
        {Credo.Check.Refactor.LongQuoteBlocks, false},
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Refactor.MapJoin},
        {Credo.Check.Refactor.MatchInCondition},
        {Credo.Check.Refactor.ModuleDependencies, false},
        {Credo.Check.Refactor.NegatedConditionsInUnless},
        {Credo.Check.Refactor.NegatedConditionsWithElse},
        {Credo.Check.Refactor.Nesting},
        {Credo.Check.Refactor.PipeChainStart, false},
        {Credo.Check.Refactor.RejectFilter},
        {Credo.Check.Refactor.RejectReject},
        {Credo.Check.Refactor.VariableRebinding, false},

        ## Warnings
        #
        {Credo.Check.Warning.ApplicationConfigInModuleAttribute, false},
        {Credo.Check.Warning.BoolOperationOnSameValues},
        {Credo.Check.Warning.IExPry},
        {Credo.Check.Warning.IoInspect},
        {Credo.Check.Warning.LazyLogging, false},
        {Credo.Check.Warning.LeakyEnvironment},
        {Credo.Check.Warning.MapGetUnsafePass},
        {Credo.Check.Warning.MixEnv},
        {Credo.Check.Warning.OperationOnSameValues},
        {Credo.Check.Warning.OperationWithConstantResult},
        {Credo.Check.Warning.RaiseInsideRescue},
        {Credo.Check.Warning.UnusedEnumOperation},
        {Credo.Check.Warning.UnusedFileOperation},
        {Credo.Check.Warning.UnusedKeywordOperation},
        {Credo.Check.Warning.UnusedListOperation},
        {Credo.Check.Warning.UnusedPathOperation},
        {Credo.Check.Warning.UnusedRegexOperation},
        {Credo.Check.Warning.UnusedStringOperation},
        {Credo.Check.Warning.UnusedTupleOperation},
        {Credo.Check.Warning.UnsafeExec}
      ]
    }
  ]
}

