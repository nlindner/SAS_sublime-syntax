# SAS Package for Sublime Text (SAS Institute) #

This began as a fork of [RPardee's SAS package](https://github.com/rpardee/sas). His package provides syntax highlighting, a build system, and autocompletions. I can't use the build system because I only have access to SAS Enterprise Guide, and I don't generally use autocompletions.

Because I spend much of my time in SAS' PROC SQL and MACRO language, I wanted to convert his base syntax definition into Sublime Text's new .sublime-syntax, use that new functionality to expand the specificity of syntax highlighting, add more of the SAS 9.4/SAS EG functionality, and develop something that works better for the kind of programming I tend to do (very few specialized procs, lots of explicit pass-through SQL). However, I wouldn't have switched from SAS to Sublime Text without his syntax definition, and this package owes its very existence to his hard work.
  - Note that to use this syntax, I disable Sublime Text's default SQL syntax and instead use [customized/expanded, SQL-Server-based SQL syntax highlighting](https://github.com/nlindner/SQL-Server_sublime-syntax). At a minimum, you should install the "SQL (override default)" directory of that repository, which includes the block-comments, strings, and string_interpolation repositories called here. This SAS syntax only highlights SQL syntax for code outside of explicit pass-through blocks (execute () or connection to ... ()), and expects that you will add in calls (e.g., source.sql-server) to any SQL dialects (besides SQL Server) that you need.

If you have any syntax highlighting problems, please don't hesitate to submit an issue with sample code.

## USAGE PATTERNS THAT DIFFER FROM ORIGINAL RPARDEE REPOSITORY ##
  - Unlike the SAS coding-style implicitly expected in RPardee's repository, my personal preference is to exclude spaces before semi-colons. It's possible that some of these regex patterns fail to allow for an optional space before a semi-colon, although I have tried to minimize that by reusing generic repositories like run-pop, runorquit-pop, and quit-pop. If you find any problems, please submit an issue with sample code.
  - At least in SAS EG, if a PROC SQL step is opened in a macro, then unless a QUIT is issued before the macro terminates, SAS' status will just show a "running" until you issue a STOP PROCESS. Heaven knows what SAS chooses to do in a scheduled process with a macro or or data step like that. Because of that, the scoping here requires that DATA step ends with RUN and PROC SQL (and other procs) end with QUIT. 
  - I've limited DATA step's begin-capture scope, I don't use data step or the specialized PROCs enough to have seen any problems resulting from this. 

### Other useful packages I use in conjunction with this ###
  - The macro "do" block (if/else/else if...then do) is MUCH easier to work with after installing [FacelessUser's BracketHighlighter package](https://packagecontrol.io/packages/BracketHighlighter). My SAS-specific additions are in my [Sublime Setup](https://github.com/nlindner/Nicole_Miscellaneous) repo under bh_core.sublime-settings

## WishList ##
  - Have finished my old wish list items, need to redo.

