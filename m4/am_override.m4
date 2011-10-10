# _AM_OUTPUT_DEPENDENCY_COMMANDS
# ------------------------------
AC_DEFUN([_AM_OUTPUT_DEPENDENCY_COMMANDS],
[{
  # Autoconf 2.62 quotes --file arguments for eval, but not when files
  # are listed without --file.  Let's play safe and only enable the eval
  # if we detect the quoting.
  case $CONFIG_FILES in
  *\'*) eval set x "$CONFIG_FILES" ;;
  *)   set x $CONFIG_FILES ;;
  esac
  shift
  for mf
  do
    # Strip MF so we end up with the name of the file.
    mf=`echo "$mf" | sed -e 's/:.*$//'`
    # Check whether this is an Automake generated Makefile or not.
    # We used to match only the files named `Makefile.in', but
    # some people rename them; so instead we look at the file content.
    # Grep'ing the first line is not enough: some people post-process
    # each Makefile.in and add a new line on top of each file to say so.
    # Grep'ing the whole file is not good either: AIX grep has a line
    # limit of 2048, but all sed's we know have understand at least 4000.
    if sed -n 's,^#.*generated by automake.*,X,p' "$mf" | grep X >/dev/null 2>&1; then
      dirpart=`AS_DIRNAME("$mf")`
    else
      continue
    fi

    # A4: Save submake output
    CACHE_DIR="${XDG_CACHE_HOME-${HOME}/.cache}/a4"
    mkdir -p "$CACHE_DIR"
    LAST_MAKE=`echo "$CACHE_DIR/last-submake" | sed -e 's/\//\\\\\//g'`
    LAST_ERROR=`echo "$CACHE_DIR/last-error" | sed -e 's/\//\\\\\//g'`
    cat $mf | sed -e "s/(\$(am__cd) \$\$subdir && \$(MAKE) \$(AM_MAKEFLAGS) \$\$local_target/& 2>\&1 | tee \"$LAST_MAKE\"; let \\\!PIPESTATUS /g" > $mf.tmp && mv $mf.tmp $mf

    # A4: Insert an error message
    ERROR_MESSAGE_1="A4: It seems that an error has occurred! :("
    ERROR_MESSAGE_2="A4: Run \"\$(top_srcdir)\/common\/a4shout.sh --last\" to report this compilation error to the A4 developers."
    echo_SEP="echo \\\"-----------------\\\""
    cat $mf | sed -e "s/failcom='exit 1'/failcom='{ mv $LAST_MAKE $LAST_ERROR 2>\/dev\/null \&\& $echo_SEP \&\& echo \"$ERROR_MESSAGE_1\" \&\& echo \"$ERROR_MESSAGE_2\" \&\& $echo_SEP; exit 1; }'/" > $mf.tmp && mv $mf.tmp $mf

    # Extract the definition of DEPDIR, am__include, and am__quote
    # from the Makefile without running `make'.
    DEPDIR=`sed -n 's/^DEPDIR = //p' < "$mf"`
    test -z "$DEPDIR" && continue
    am__include=`sed -n 's/^am__include = //p' < "$mf"`
    test -z "am__include" && continue
    am__quote=`sed -n 's/^am__quote = //p' < "$mf"`
    # When using ansi2knr, U may be empty or an underscore; expand it
    U=`sed -n 's/^U = //p' < "$mf"`
    # Find all dependency output files, they are included files with
    # $(DEPDIR) in their names.  We invoke sed twice because it is the
    # simplest approach to changing $(DEPDIR) to its actual value in the
    # expansion.
    for origfile in `sed -n "
      s/^$am__include $am__quote\(.*(DEPDIR).*\)$am__quote"'$/\1/p' <"$mf"`; do
      file=`echo $origfile | sed -e 's/\$(DEPDIR)/'"$DEPDIR"'/g' -e 's/\$U/'"$U"'/g'`;
      # Make sure the directory exists.
      # echo "DIRPART / FILE IS $dirpart / $file"
      # do not create directories with variable names, also make them -includes (silent)
      edit=`echo "s|^include $origfile|-include $origfile|" | sed -e 's/\\\$/\\\\\$/g'`
      test x`echo $file | grep \(` != x && cat "$mf" | sed -e "$edit" > "$mf.sed_tmp" && mv "$mf.sed_tmp" "$mf" && continue
      test -f "$dirpart/$file" && continue
      fdir=`AS_DIRNAME(["$file"])`
      AS_MKDIR_P([$dirpart/$fdir])
      # echo "creating $dirpart/$file"
      echo '# dummy' > "$dirpart/$file"
    done
  done
}
])# _AM_OUTPUT_DEPENDENCY_COMMANDS
