########################################################################################
#
#    This file was generated using Parse::Eyapp version 1.181.
#
# (c) Parse::Yapp Copyright 1998-2001 Francois Desarmenien.
# (c) Parse::Eyapp Copyright 2006-2008 Casiano Rodriguez-Leon. Universidad de La Laguna.
#        Don't edit this file, use source file 'src/sh.yp' instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
########################################################################################
package ShParser;
use strict;

push @ShParser::ISA, 'Parse::Eyapp::Driver';



  # Loading Parse::Eyapp::Driver
  BEGIN {
    unless (Parse::Eyapp::Driver->can('YYParse')) {
      eval << 'MODULE_Parse_Eyapp_Driver'
#
# Module Parse::Eyapp::Driver
#
# This module is part of the Parse::Eyapp package available on your
# nearest CPAN
#
# This module is based on Francois Desarmenien Parse::Yapp module
# (c) Parse::Yapp Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (c) Parse::Eyapp Copyright 2006-2010 Casiano Rodriguez-Leon, all rights reserved.

our $SVNREVISION = '$Rev: 2399M $';
our $SVNDATE     = '$Date: 2009-01-06 12:28:04 +0000 (mar, 06 ene 2009) $';

package Parse::Eyapp::Driver;

require 5.006;

use strict;

our ( $VERSION, $COMPATIBLE, $FILENAME );


# $VERSION is also in Parse/Eyapp.pm
$VERSION = "1.181";
$COMPATIBLE = '0.07';
$FILENAME   =__FILE__;

use Carp;
use Scalar::Util qw{blessed reftype looks_like_number};

use Getopt::Long;

#Known parameters, all starting with YY (leading YY will be discarded)
my (%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
       YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '', 
       # added by Casiano
       #YYPREFIX  => '',  # Not allowed at YYParse time but in new
       YYFILENAME => '', 
       YYBYPASS   => '',
       YYGRAMMAR  => 'ARRAY', 
       YYTERMS    => 'HASH',
       YYBUILDINGTREE  => '',
       YYACCESSORS => 'HASH',
       YYCONFLICTHANDLERS => 'HASH',
       YYSTATECONFLICT => 'HASH',
       YYLABELS => 'HASH',
       ); 
my (%newparams) = (%params, YYPREFIX => '',);

#Mandatory parameters
my (@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;

    my($errst,$nberr,$token,$value,$check,$dotpos);

    my($self)={ 
      ERRST => \$errst,
      NBERR => \$nberr,
      TOKEN => \$token,
      VALUE => \$value,
      DOTPOS => \$dotpos,
      STACK => [],
      DEBUG => 0,
      PREFIX => "",
      CHECK => \$check, 
    };

  _CheckParams( [], \%newparams, \@_, $self );

    exists($$self{VERSION})
  and $$self{VERSION} < $COMPATIBLE
  and croak "Eyapp driver version $VERSION ".
        "incompatible with version $$self{VERSION}:\n".
        "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    unless($self->{ERROR}) {
      $self->{ERROR} = $class->error;
      $self->{ERROR} = \&_Error unless ($self->{ERROR});
    }

    unless ($self->{LEX}) {
        $self->{LEX} = $class->YYLexer;
        @params = ('RULES','STATES');
    }

    my $parser = bless($self,$class);

    $parser;
}

sub YYParse {
    my($self)=shift;
    my($retval);

  _CheckParams( \@params, \%params, \@_, $self );

  unless($self->{ERROR}) {
    $self->{ERROR} = $self->error;
    $self->{ERROR} = \&_Error unless ($self->{ERROR});
  }

  unless($self->{LEX}) {
    $self->{LEX} = $self->YYLexer;
    croak "Missing parameter 'yylex' " unless $self->{LEX} && reftype($self->{LEX}) eq 'CODE';
  }

  if($$self{DEBUG}) {
    _DBLoad();
    $retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
  }
  else {
    $retval = $self->_Parse();
  }
    return $retval;
}

sub YYData {
  my($self)=shift;

    exists($$self{USER})
  or  $$self{USER}={};

  $$self{USER};
  
}

sub YYErrok {
  my($self)=shift;

  ${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
  my($self)=shift;

  ${$$self{NBERR}};
}

sub YYRecovering {
  my($self)=shift;

  ${$$self{ERRST}} != 0;
}

sub YYAbort {
  my($self)=shift;

  ${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
  my($self)=shift;

  ${$$self{CHECK}}='ACCEPT';
    undef;
}

# Used to set that we are in "error recovery" state
sub YYError {
  my($self)=shift;

  ${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
  my($self)=shift;
  my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

    $index < 0
  and -$index <= @{$$self{STACK}}
  and return $$self{STACK}[$index][1];

  undef;  #Invalid index
}

### Casiano methods

sub YYRule { 
  # returns the list of rules
  # counting the super rule as rule 0
  my $self = shift;
  my $index = shift;

  if ($index) {
    $index = $self->YYIndex($index) unless (looks_like_number($index));
    return wantarray? @{$self->{RULES}[$index]} : $self->{RULES}[$index]
  }

  return wantarray? @{$self->{RULES}} : $self->{RULES}
}

# YYState returns the list of states. Each state is an anonymous hash
#  DB<4> x $parser->YYState(2)
#  0  HASH(0xfa7120)
#     'ACTIONS' => HASH(0xfa70f0) # token => state
#           ':' => '-7'
#     'DEFAULT' => '-6'
# There are three keys: ACTIONS, GOTOS and  DEFAULT
#  DB<7> x $parser->YYState(13)
# 0  HASH(0xfa8b50)
#    'ACTIONS' => HASH(0xfa7530)
#       'VAR' => 17
#    'GOTOS' => HASH(0xfa8b20)
#       'type' => 19
sub YYState {
  my $self = shift;
  my $index = shift;

  if ($index) {
    # Comes from the stack: a pair [state number, attribute]
    $index = $index->[0] if 'ARRAY' eq reftype($index);
    die "YYState error. Expecting a number, found <$index>" unless (looks_like_number($index));
    return $self->{STATES}[$index]
  }

  return $self->{STATES}
}

sub YYGoto {
  my ($self, $state, $symbol) = @_;
 
  my $stateLRactions = $self->YYState($state);

  $stateLRactions->{GOTOS}{$symbol};
}

sub YYRHSLength {
  my $self = shift;
  # If no production index is given, is the production begin used in the current reduction
  my $index = shift || $self->YYRuleindex;

  # If the production was given by its name, compute its index
  $index = $self->YYIndex($index) unless looks_like_number($index); 
  
  return unless looks_like_number($index);

  my $currentprod = $self->YYRule($index);

  $currentprod->[1] if reftype($currentprod);
}

# To be used in a semantic action, when reducing ...
# It gives the next state after reduction
sub YYNextState {
  my $self = shift;

  my $lhs = $self->YYLhs;

  if ($lhs) { # reduce
    my $length = $self->YYRHSLength;

    my $state = $self->YYTopState($length);
    #print "state = $$state[0]\n";
    $self->YYGoto($state, $lhs);
  }
  else { # shift: a token must be provided as argument
    my $token = shift;
    
    my $state = $self->YYTopState;
    $self->YYGetLRAction($state, $token);
  }
}

# TODO: make it work with a list of indices ...
sub YYGrammar { 
  my $self = shift;
  my $index = shift;

  if ($index) {
    $index = $self->YYIndex($index) unless (looks_like_number($index));
    return wantarray? @{$self->{GRAMMAR}[$index]} : $self->{GRAMMAR}[$index]
  }
  return wantarray? @{$self->{GRAMMAR}} : $self->{GRAMMAR}
}

# Return the list of production names
sub YYNames { 
  my $self = shift;

  my @names = map { $_->[0] } @{$self->{GRAMMAR}};

  return wantarray? @names : \@names;
}

# Return the hash of indices  for each production name
# Initializes the INDICES attribute of the parser
# Returns the index of the production rule with name $name
sub YYIndex {
  my $self = shift;

  if (@_) {
    my @indices = map { $self->{LABELS}{$_} } @_;
    return wantarray? @indices : $indices[0];
  }
  return wantarray? %{$self->{LABELS}} : $self->{LABELS};

}

sub YYTopState {
  my $self = shift;
  my $length = shift || 0;

  $length = -$length unless $length <= 0;
  $length--;

  $_[1] and $self->{STACK}[$length] = $_[1];
  $self->{STACK}[$length];
}

sub YYStack {
  my $self = shift;

  return $self->{STACK};
}

# To dynamically set syntactic actions
# Change it to state, token, action
# it is more natural
sub YYSetLRAction {
  my ($self,  $state, $token, $action) = @_;

  die "YYLRAction: Provide a state " unless defined($state);

  # Action can be given using the name of the production
  $action = -$self->YYIndex($action) unless looks_like_number($action);
  $token = [ $token ] unless ref($token);
  for (@$token) {
    $self->{STATES}[$state]{ACTIONS}{$_} = $action;
  }
}

sub YYRestoreLRAction {
  my $self = shift;
  my $conflictname = shift;
  my @tokens = @_;

  for (@tokens) {
    my ($conflictstate, $action) = @{$self->{CONFLICT}{$conflictname}{$_}};
    $self->{STATES}[$conflictstate]{ACTIONS}{$_} = $action;
  }
}

# Fools the lexer to get a new token
# without modifying the parsing position (pos)
# Warning, warning! this and YYLookaheads assume
# that the input comes from the string
# referenced by $self->input.
# It will not work for a stream 
sub YYLookahead {
  my $self = shift;

  my $pos = pos(${$self->input});
  my ($nextToken, $val) = $self->YYLexer->($self);
  # restore pos
  pos(${$self->input}) = $pos;
  return $nextToken;
}

# Fools the lexer to get $spec new tokens
sub YYLookaheads {
  my $self = shift;
  my $spec = shift || 1; # a number

  my $pos = pos(${$self->input});
  my @r; # list of lookahead tokens

  my ($t, $v);
  if (looks_like_number($spec)) {
    for my $i (1..$spec) { 
      ($t, $v) = $self->YYLexer->($self);
      push @r, $t;
      last if $t eq '';
    }
  }
  else { # if string
    do {
      ($t, $v) = $self->YYLexer->($self);
      push @r, $t;
    } while ($t ne $spec && $t ne '');
  }

  # restore pos
  pos(${$self->input}) = $pos;

  return @r;
}


# more parameters: debug, etc, ...
#sub YYNestedParse {
sub YYPreParse {
  my $self = shift; 
  my $parser = shift;
  my $file = shift() || $parser;

  # Check for errors!
  eval "require $file";
   
  # optimize to state variable for 5.10
  my $rp = $parser->new( yyerror => sub {});

  my $pos  = pos(${$self->input});
  my $rpos = $self->{POS};

  #print "pos = $pos\n";
  $rp->input($self->input);
  pos(${$rp->input}) = $rpos;

  my $t = $rp->Run(@_);
  my $ne = $rp->YYNberr;

  #print "After nested parsing\n";

  pos(${$self->input}) = $pos;

  return (wantarray ? ($t, !$ne) : !$ne);
}

sub YYNestedParse {
  my $self = shift;
  my $parser = shift;
  my $conflictName =  shift;

  $conflictName = $self->YYLhs unless $conflictName;

  my ($t, $ok) = $self->YYPreParse($parser, @_);

  $self->{CONFLICTHANDLERS}{$conflictName}{".".$parser} = [$ok, $t];

  return $ok;
}

sub YYNestedRegexp {
  my $self = shift;
  my $regexp = shift;
  my $conflictName = $self->YYLhs;

  my $ok = $_ =~ /$regexp/gc;

  $self->{CONFLICTHANDLERS}{$conflictName}{'..regexp'} = [$ok, undef];

  return $ok;
}

sub YYIs {
  my $self = shift;
  # this is ungly and dangeorus. Don't use the dot. Change it!
  my $syntaxVariable = '.'.(shift());
  my $conflictName = $self->YYLhs;
  my $v = $self->{CONFLICTHANDLERS}{$conflictName};

  $v->{$syntaxVariable}[0] = shift if @_;
  return $v->{$syntaxVariable}[0];
}


sub YYVal {
  my $self = shift;
  # this is ungly and dangeorus. Don't use the dot. Change it!
  my $syntaxVariable = '.'.(shift());
  my $conflictName = $self->YYLhs;
  my $v = $self->{CONFLICTHANDLERS}{$conflictName};

  $v->{$syntaxVariable}[1] = shift if @_;
  return $v->{$syntaxVariable}[1];
}

#x $self->{CONFLICTHANDLERS}                                                                              
#0  HASH(0x100b306c0)
#   'rangeORenum' => HASH(0x100b30660)
#      'explorerline' => 12
#      'line' => 5
#      'production' => HASH(0x100b30580)
#         '-13' => ARRAY(0x100b30520)
#            0  1 <------- mark: conflictive position in the rhs 
#         '-5' => ARRAY(0x100b30550)
#            0  1 <------- mark: conflictive position in the rhs 
#      'states' => ARRAY(0x100b30630)
#         0  HASH(0x100b30600)
#            25 => ARRAY(0x100b305c0)
#               0  '\',\''
#               1  '\')\''
sub YYSetReduceXXXXX {
  my $self = shift;
  my $action = pop;
  my $token = shift;
  

  croak "YYSetReduce error: specify a production" unless defined($action);

  # Conflict state
  my $conflictstate = $self->YYNextState();

  my $conflictName = $self->YYLhs;

  #$self->{CONFLICTHANDLERS}{conflictName}{states}
  # is a hash
  #        statenumber => [ tokens, '\'-\'' ]
  my $cS = $self->{CONFLICTHANDLERS}{$conflictName}{states};
  my @conflictStates = $cS ? @$cS : ();

  # Perform the action to change the LALR tables only if the next state 
  # is listed as a conflictstate
  my ($cs) = (grep { exists $_->{$conflictstate}} @conflictStates); 
  return unless $cs;

  # Action can be given using the name of the production
  unless (looks_like_number($action)) {
    my $actionnum = $self->{LABELS}{$action};
    unless (looks_like_number($actionnum)) {
      croak "YYSetReduce error: can't find production '$action'. Did you forget to name it?";
    }
    $action = -$actionnum;
  }

  $token = $cs->{$conflictstate} unless defined($token);
  $token = [ $token ] unless ref($token);
  for (@$token) {
    # save if shift
    if (exists($self->{STATES}[$conflictstate]{ACTIONS}) and $self->{STATES}[$conflictstate]{ACTIONS}{$_} >= 0) {
      $self->{CONFLICT}{$conflictName}{$_}  = [ $conflictstate,  $self->{STATES}[$conflictstate]{ACTIONS}{$_} ];
    }
    $self->{STATES}[$conflictstate]{ACTIONS}{$_} = $action;
  }
}

sub YYSetReduce {
  my $self = shift;
  my $action = pop;
  my $token = shift;
  

  croak "YYSetReduce error: specify a production" unless defined($action);

  my $conflictName = $self->YYLhs;

  #$self->{CONFLICTHANDLERS}{conflictName}{states}
  # is a hash
  #        statenumber => [ tokens, '\'-\'' ]
  my $cS = $self->{CONFLICTHANDLERS}{$conflictName}{states};
  my @conflictStates = $cS ? @$cS : ();
 
  return unless @conflictStates;

  # Conflict state
  my $cs = $conflictStates[0];


  my ($conflictstate) = keys %{$cs};

  # Action can be given using the name of the production
  unless (looks_like_number($action)) {
    my $actionnum = $self->{LABELS}{$action};
    unless (looks_like_number($actionnum)) {
      croak "YYSetReduce error: can't find production '$action'. Did you forget to name it?";
    }
    $action = -$actionnum;
  }

  $token = $cs->{$conflictstate} unless defined($token);
  $token = [ $token ] unless ref($token);
  for (@$token) {
    # save if shift
    if (exists($self->{STATES}[$conflictstate]{ACTIONS}) and $self->{STATES}[$conflictstate]{ACTIONS}{$_} >= 0) {
      $self->{CONFLICT}{$conflictName}{$_}  = [ $conflictstate,  $self->{STATES}[$conflictstate]{ACTIONS}{$_} ];
    }
    $self->{STATES}[$conflictstate]{ACTIONS}{$_} = $action;
  }
}

sub YYSetShift {
  my ($self, $token) = @_;

  # my ($self, $token, $action) = @_;
  # $action is syntactic sugar ...


  my $conflictName = $self->YYLhs;

  my $cS = $self->{CONFLICTHANDLERS}{$conflictName}{states};
  my @conflictStates = $cS ? @$cS : ();
 
  return unless @conflictStates;

  my $cs = $conflictStates[0];

  my ($conflictstate) = keys %{$cs};

  $token = $cs->{$conflictstate} unless defined($token);
  $token = [ $token ] unless ref($token);

  for (@$token) {
    if (defined($self->{CONFLICT}{$conflictName}{$_}))  {
      my ($conflictstate2, $action) = @{$self->{CONFLICT}{$conflictName}{$_}};
      # assert($conflictstate == $conflictstate2) 

      $self->{STATES}[$conflictstate]{ACTIONS}{$_} = $self->{CONFLICT}{$conflictName}{$_}[1];
    }
    else {
      #croak "YYSetShift error. No shift action found";
      # shift is the default ...  hope to be lucky!
    }
  }
}


  # if is reduce ...
    # x $self->{CONFLICTHANDLERS}{$conflictName}{production}{$action} $action is a number
    #0  ARRAY(0x100b3f930)
    #   0  2
    # has the position in the item, starting at 0
    # DB<19> x $self->YYRHSLength(4)
    # 0  3
    # if pos is length -1 then is reduce otherwise is shift


# It does YYSetReduce or YYSetshift according to the 
# decision variable
# I need to know the kind of conflict that there is
# shift-reduce or reduce-reduce
sub YYIf {
  my $self = shift;
  my $syntaxVariable = shift;

  if ($self->YYIs($syntaxVariable)) {
    if ($_[0] eq 'shift') {
      $self->YYSetShift(@_); 
    }
    else {
      $self->YYSetReduce($_[0]); 
    }
  }
  else {
    if ($_[1] eq 'shift') {
      $self->YYSetShift(@_); 
    }
    else {
      $self->YYSetReduce($_[1]); 
    }
  }
  $self->YYIs($syntaxVariable, 0); 
}

sub YYGetLRAction {
  my ($self,  $state, $token) = @_;

  $state = $state->[0] if reftype($state) && (reftype($state) eq 'ARRAY');
  my $stateentry = $self->{STATES}[$state];

  if (defined($token)) {
    return $stateentry->{ACTIONS}{$token} if exists $stateentry->{ACTIONS}{$token};
  }

  return $stateentry->{DEFAULT} if exists $stateentry->{DEFAULT};

  return;
}

# to dynamically set semantic actions
sub YYAction {
  my $self = shift;
  my $index = shift;
  my $newaction = shift;

  croak "YYAction error: Expecting an index" unless $index;

  # If $index is the production 'name' find the actual index
  $index = $self->YYIndex($index) unless looks_like_number($index);
  my $rule = $self->{RULES}->[$index];
  $rule->[2] = $newaction if $newaction && (reftype($newaction) eq 'CODE');

  return $rule->[2];
}

sub YYSetaction {
  my $self = shift;
  my %newaction = @_;

  for my $n (keys(%newaction)) {
    my $m = looks_like_number($n) ? $n : $self->YYIndex($n);
    my $rule = $self->{RULES}->[$m];
    $rule->[2] = $newaction{$n} if ($newaction{$n} && (reftype($newaction{$n}) eq 'CODE'));
  }
}

#sub YYDebugtree  {
#  my ($self, $i, $e) = @_;
#
#  my ($name, $lhs, $rhs) = @$e;
#  my @rhs = @$rhs;
#
#  return if $name =~ /_SUPERSTART/;
#  $name = $lhs."::"."@rhs";
#  $name =~ s/\W/_/g;
#  return $name;
#}
#
#sub YYSetnames {
#  my $self = shift;
#  my $newname = shift || \&YYDebugtree;
#
#    die "YYSetnames error. Exected a CODE reference found <$newname>" 
#  unless $newname && (reftype($newname) eq 'CODE');
#
#  my $i = 0;
#  for my $e (@{$self->{GRAMMAR}}) {
#     my $nn= $newname->($self, $i, $e);
#     $e->[0] = $nn if defined($nn);
#     $i++;
#  }
#}

sub YYLhs { 
  # returns the syntax variable on
  # the left hand side of the current production
  my $self = shift;

  return $self->{CURRENT_LHS}
}

sub YYRuleindex { 
  # returns the index of the rule
  # counting the super rule as rule 0
  my $self = shift;

  return $self->{CURRENT_RULE}
}

sub YYRightside { 
  # returns the rule
  # counting the super rule as rule 0
  my $self = shift;
  my $index = shift || $self->{CURRENT_RULE};
  $index = $self->YYIndex($index) unless looks_like_number($index);

  return @{$self->{GRAMMAR}->[$index]->[2]};
}

sub YYTerms {
  my $self = shift;

  return $self->{TERMS};
}


sub YYIsterm {
  my $self = shift;
  my $symbol = shift;

  return exists ($self->{TERMS}->{$symbol});
}

sub YYIssemantic {
  my $self = shift;
  my $symbol = shift;

  return 0 unless exists($self->{TERMS}{$symbol});
  $self->{TERMS}{$symbol}{ISSEMANTIC} = shift if @_;
  return ($self->{TERMS}{$symbol}{ISSEMANTIC});
}

sub YYName {
  my $self = shift;

  my $current_rule = $self->{GRAMMAR}->[$self->{CURRENT_RULE}];
  $current_rule->[0] = shift if @_;
  return $current_rule->[0];
}

sub YYPrefix {
  my $self = shift;

  $self->{PREFIX} = $_[0] if @_;
  $self->{PREFIX};
}

sub YYAccessors {
  my $self = shift;

  $self->{ACCESSORS}
}

# name of the file containing
# the source grammar
sub YYFilename {
  my $self = shift;

  $self->{FILENAME} = $_[0] if @_;
  $self->{FILENAME};
}

sub YYBypass {
  my $self = shift;

  $self->{BYPASS} = $_[0] if @_;
  $self->{BYPASS};
}

sub YYBypassrule {
  my $self = shift;

  $self->{GRAMMAR}->[$self->{CURRENT_RULE}][3] = $_[0] if @_;
  return $self->{GRAMMAR}->[$self->{CURRENT_RULE}][3];
}

sub YYFirstline {
  my $self = shift;

  $self->{FIRSTLINE} = $_[0] if @_;
  $self->{FIRSTLINE};
}

# Used as default action when writing a reusable grammar.
# See files examples/recycle/NoacInh.eyp 
# and examples/recycle/icalcu_and_ipost.pl 
# in the Parse::Eyapp distribution
sub YYDelegateaction {
  my $self = shift;

  my $action = $self->YYName;
  
  $self->$action(@_);
}

# Influences the behavior of YYActionforT_X1X2
# YYActionforT_single and YYActionforT_empty
# If true these methods will build simple lists of attributes 
# for the lists operators X*, X+ and X? and parenthesis (X Y)
# Otherwise the classic node construction for the
# syntax tree is used
sub YYBuildingTree {
  my $self = shift;

  $self->{BUILDINGTREE} = $_[0] if @_;
  $self->{BUILDINGTREE};
}

sub BeANode {
  my $class = shift;

    no strict 'refs';
    push @{$class."::ISA"}, "Parse::Eyapp::Node" unless $class->isa("Parse::Eyapp::Node");
}

#sub BeATranslationScheme {
#  my $class = shift;
#
#    no strict 'refs';
#    push @{$class."::ISA"}, "Parse::Eyapp::TranslationScheme" unless $class->isa("Parse::Eyapp::TranslationScheme");
#}

{
  my $attr =  sub { 
      $_[0]{attr} = $_[1] if @_ > 1;
      $_[0]{attr}
    };

  sub make_node_classes {
    my $self = shift;
    my $prefix = $self->YYPrefix() || '';

    { no strict 'refs';
      *{$prefix."TERMINAL::attr"} = $attr;
    }

    for (@_) {
       my ($class) = split /:/, $_;
       BeANode("$prefix$class"); 
    }

    my $accessors = $self->YYAccessors();
    for (keys %$accessors) {
      my $position = $accessors->{$_};
      no strict 'refs';
      *{$prefix.$_} = sub {
        my $self = shift;

        return $self->child($position, @_)
      }
    } # for
  }
}

####################################################################
# Usage      : ????
# Purpose    : Responsible for the %tree directive 
#              On each production the default action becomes:
#              sub { goto &Parse::Eyapp::Driver::YYBuildAST }
#
# Returns    : ????
# Parameters : ????
# Throws     : no exceptions
# Comments   : none
# See Also   : n/a
# To Do      : many things: Optimize this!!!!
sub YYBuildAST { 
  my $self = shift;
  my $PREFIX = $self->YYPrefix();
  my @right = $self->YYRightside(); # Symbols on the right hand side of the production
  my $lhs = $self->YYLhs;
  my $fullname = $self->YYName();
  my ($name) = split /:/, $fullname;
  my $bypass = $self->YYBypassrule; # Boolean: shall we do bypassing of lonely nodes?
  my $class = "$PREFIX$name";
  my @children;

  my $node = bless {}, $class;

  for(my $i = 0; $i < @right; $i++) {
    local $_ = $right[$i]; # The symbol
    my $ch = $_[$i]; # The attribute/reference

    # is $ch already a Parse::Eyapp::Node. May be a terminal and a syntax variable share the same name?
    unless (UNIVERSAL::isa($ch, 'Parse::Eyapp::Node')) {
      if ($self->YYIssemantic($_)) {
        my $class = $PREFIX.'TERMINAL';
        my $node = bless { token => $_, attr => $ch, children => [] }, $class;
        push @children, $node;
        next;
      }

      if ($self->YYIsterm($_)) {
        TERMINAL::save_attributes($ch, $node) if UNIVERSAL::can($PREFIX."TERMINAL", "save_attributes");
        next;
      }
    }

    if (UNIVERSAL::isa($ch, $PREFIX."_PAREN")) { # Warning: weak code!!!
      push @children, @{$ch->{children}};
      next;
    }

    # If it is an intermediate semantic action skip it
    next if $_ =~ qr{@}; # intermediate rule
    next unless ref($ch);
    push @children, $ch;
  }

  
  if ($bypass and @children == 1) {
    $node = $children[0]; 

    my $childisterminal = ref($node) =~ /TERMINAL$/;
    # Re-bless unless is "an automatically named node", but the characterization of this is 
    bless $node, $class unless $name =~ /${lhs}_\d+$/; # lazy, weak (and wicked).

   
    my $finalclass =  ref($node);
    $childisterminal and !$finalclass->isa($PREFIX.'TERMINAL') 
      and do { 
        no strict 'refs';
        push @{$finalclass."::ISA"}, $PREFIX.'TERMINAL' 
      };

    return $node;
  }
  $node->{children} = \@children; 
  return $node;
}

sub YYBuildTS { 
  my $self = shift;
  my $PREFIX = $self->YYPrefix();
  my @right = $self->YYRightside(); # Symbols on the right hand side of the production
  my $lhs = $self->YYLhs;
  my $fullname = $self->YYName();
  my ($name) = split /:/, $fullname;
  my $class;
  my @children;

  for(my $i = 0; $i < @right; $i++) {
    local $_ = $right[$i]; # The symbol
    my $ch = $_[$i]; # The attribute/reference

    if ($self->YYIsterm($_)) { 
      $class = $PREFIX.'TERMINAL';
      push @children, bless { token => $_, attr => $ch, children => [] }, $class;
      next;
    }

    if (UNIVERSAL::isa($ch, $PREFIX."_PAREN")) { # Warning: weak code!!!
      push @children, @{$ch->{children}};
      next;
    }

    # Substitute intermediate code node _CODE(CODE()) by CODE()
    if (UNIVERSAL::isa($ch, $PREFIX."_CODE")) { # Warning: weak code!!!
      push @children, $ch->child(0);
      next;
    }

    next unless ref($ch);
    push @children, $ch;
  }

  if (unpack('A1',$lhs) eq '@') { # class has to be _CODE check
          $lhs =~ /^\@[0-9]+\-([0-9]+)$/
      or  croak "In line rule name '$lhs' ill formed: report it as a BUG.\n";
      my $dotpos = $1;
 
      croak "Fatal error building metatree when processing  $lhs -> @right" 
      unless exists($_[$dotpos]) and UNIVERSAL::isa($_[$dotpos], 'CODE') ; 
      push @children, $_[$dotpos];
  }
  else {
    my $code = $_[@right];
    if (UNIVERSAL::isa($code, 'CODE')) {
      push @children, $code; 
    }
    else {
      croak "Fatal error building translation scheme. Code or undef expected" if (defined($code));
    }
  }

  $class = "$PREFIX$name";
  my $node = bless { children => \@children }, $class; 
  $node;
}

sub YYActionforT_TX1X2_tree {
  my $self = shift;
  my $head = shift;
  my $PREFIX = $self->YYPrefix();
  my @right = $self->YYRightside();
  my $class;

  for(my $i = 1; $i < @right; $i++) {
    local $_ = $right[$i];
    my $ch = $_[$i-1];
    if ($self->YYIssemantic($_)) {
      $class = $PREFIX.'TERMINAL';
      push @{$head->{children}}, bless { token => $_, attr => $ch, children => [] }, $class;
      
      next;
    }
    next if $self->YYIsterm($_);
    if (ref($ch) eq  $PREFIX."_PAREN") { # Warning: weak code!!!
      push @{$head->{children}}, @{$ch->{children}};
      next;
    }
    next unless ref($ch);
    push @{$head->{children}}, $ch;
  }

  return $head;
}

# For * and + lists 
# S2 -> S2 X         { push @$_[1] the node associated with X; $_[1] }
# S2 -> /* empty */  { a node with empty children }
sub YYActionforT_TX1X2 {
  goto &YYActionforT_TX1X2_tree if $_[0]->YYBuildingTree;

  my $self = shift;
  my $head = shift;

  push @$head, @_;
  return $head;
}

sub YYActionforParenthesis {
  goto &YYBuildAST if $_[0]->YYBuildingTree;

  my $self = shift;

  return [ @_ ];
}


sub YYActionforT_empty_tree {
  my $self = shift;
  my $PREFIX = $self->YYPrefix();
  my $name = $self->YYName();

  # Allow use of %name
  my $class = $PREFIX.$name;
  my $node = bless { children => [] }, $class;
  #BeANode($class);
  $node;
}

sub YYActionforT_empty {
  goto &YYActionforT_empty_tree  if $_[0]->YYBuildingTree;

  [];
}

sub YYActionforT_single_tree {
  my $self = shift;
  my $PREFIX = $self->YYPrefix();
  my $name = $self->YYName();
  my @right = $self->YYRightside();
  my $class;

  # Allow use of %name
  my @t;
  for(my $i = 0; $i < @right; $i++) {
    local $_ = $right[$i];
    my $ch = $_[$i];
    if ($self->YYIssemantic($_)) {
      $class = $PREFIX.'TERMINAL';
      push @t, bless { token => $_, attr => $ch, children => [] }, $class;
      #BeANode($class);
      next;
    }
    next if $self->YYIsterm($_);
    if (ref($ch) eq  $PREFIX."_PAREN") { # Warning: weak code!!!
      push @t, @{$ch->{children}};
      next;
    }
    next unless ref($ch);
    push @t, $ch;
  }
  $class = $PREFIX.$name;
  my $node = bless { children => \@t }, $class;
  #BeANode($class);
  $node;
}

sub YYActionforT_single {
  goto &YYActionforT_single_tree  if $_[0]->YYBuildingTree;

  my $self = shift;
  [ @_ ];
}

### end Casiano methods

sub YYCurtok {
  my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
  my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

{
  sub YYSimStack {
    my $self = shift;
    my $stack = shift;
    my @reduce = @_;
    my @expected;

    for my $index (@reduce) {
      my ($lhs, $length) = @{$self->{RULES}[-$index]};
      if (@$stack > $length) {
        my @auxstack = @$stack;
        splice @auxstack, -$length if $length;

        my $state = $auxstack[-1]->[0];
        my $nextstate = $self->{STATES}[$state]{GOTOS}{$lhs};
        if (defined($nextstate)) {
          push @auxstack, [$nextstate, undef];
          push @expected, $self->YYExpected(\@auxstack);
        }
      }
      # else something went wrong!!! See Frank Leray report
    }

    return map { $_ => 1 } @expected;
  }

  sub YYExpected {
    my($self)=shift;
    my $stack = shift;

    # The state in the top of the stack
    my $state = $self->{STATES}[$stack->[-1][0]];

    my %actions;
    %actions = %{$state->{ACTIONS}} if exists $state->{ACTIONS};

    # The keys of %reduction are the -production numbers
    # Use hashes and not lists to guarantee that no tokens are repeated
    my (%expected, %reduce); 
    for (keys(%actions)) {
      if ($actions{$_} > 0) { # shift
        $expected{$_} = 1;
        next;
      }
      $reduce{$actions{$_}} = 1;
    }
    $reduce{$state->{DEFAULT}} = 1 if exists($state->{DEFAULT});

    if (keys %reduce) {
      %expected = (%expected, $self->YYSimStack($stack, keys %reduce));
    }
    
    return keys %expected;
  }

  sub YYExpect {
    my $self = shift;
    $self->YYExpected($self->{STACK}, @_);
  }
}

# $self->expects($token) : returns true if the token is among the expected ones
sub expects {
  my $self = shift;
  my $token = shift;

  my @expected = $self->YYExpect;
  return grep { $_ eq $token } @expected;
}

BEGIN {
*YYExpects = \&expects;
}

# Set/Get a static/class attribute for $class
# Searches the $class ancestor tree for  an ancestor
# having defined such attribute. If found, that value is returned
sub static_attribute { 
    my $class = shift;
    $class = ref($class) if ref($class);
    my $attributename = shift;

    # class/static method
    no strict 'refs';
    my $classlexer;
    my $classname = $classlexer = $class.'::'.$attributename;
    if (@_) {
      ${$classlexer} = shift;
    }

    return ${$classlexer} if defined($$classlexer);
   
    # Traverse the inheritance tree for a defined
    # version of the attribute
    my @classes = @{$class.'::ISA'};
    my %classes = map { $_ => undef } @classes;
    while (@classes) {
      my $c = shift @classes || return;  
      $classlexer = $c.'::'.$attributename;
      if (defined($$classlexer)) {
        $$classname = $$classlexer;
        return $$classlexer;
      }
      # push those that aren't already there
      push @classes, grep { !exists $classes{$_} } @{$c.'::ISA'};
    }
    return undef;
}

sub YYEndOfInput {
   my $self = shift;

   for (${$self->input}) {
     return !defined($_) || ($_ eq '') || (defined(pos($_)) && (pos($_) >= length($_)));
   }
}

#################
# Private stuff #
#################


sub _CheckParams {
  my ($mandatory,$checklist,$inarray,$outhash)=@_;
  my ($prm,$value);
  my ($prmlst)={};

  while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
      exists($$checklist{$prm})
    or  croak("Unknown parameter '$prm'");
      ref($value) eq $$checklist{$prm}
    or  croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
    $$outhash{$prm}=$value;
  }
  for (@$mandatory) {
      exists($$outhash{$_})
    or  croak("Missing mandatory parameter '".lc($_)."'");
  }
}

#################### TailSupport ######################
sub line {
  my $self = shift;

  if (ref($self)) {
    $self->{TOKENLINE} = shift if @_;

    return $self->static_attribute('TOKENLINE', @_,) unless defined($self->{TOKENLINE}); # class/static method 
    return $self->{TOKENLINE};
  }
  else { # class/static method
    return $self->static_attribute('TOKENLINE', @_,); # class/static method 
  }
}

# attribute to count the lines
sub tokenline {
  my $self = shift;

  if (ref($self)) {
    $self->{TOKENLINE} += shift if @_;

    return $self->static_attribute('TOKENLINE', @_,) unless defined($self->{TOKENLINE}); # class/static method 
    return $self->{TOKENLINE};
  }
  else { # class/static method
    return $self->static_attribute('TOKENLINE', @_,); # class/static method 
  }
}

our $ERROR = \&_Error;
sub error {
  my $self = shift;

  if (ref $self) { # instance method
    $self->{ERROR} = shift if @_;

    return $self->static_attribute('ERROR', @_,) unless defined($self->{ERROR}); # class/static method 
    return $self->{ERROR};
  }
  else { # class/static method
    return $self->static_attribute('ERROR', @_,); # class/static method 
  }
}

# attribute with the input
# is a reference to the actual input
# slurp_file. 
# Parameters: object or class, filename, prompt messagge, mode (interactive or not: undef or "\n")
*YYSlurpFile = \&slurp_file;
sub slurp_file {
  my $self = shift;
  my $fn = shift;
  my $f;

  my $mode = undef;
  if ($fn && -r $fn) {
    open $f, $fn  or die "Can't find file '$fn'!\n";
  }
  else {
    $f = \*STDIN;
    my $msg = $self->YYPrompt();
    $mode = shift;
    print($msg) if $msg;
  }
  $self->YYInputFile($f);

  local $/ = $mode;
  my $input = <$f>;

  if (ref($self)) {  # called as object method
    $self->input(\$input);
  }
  else { # class/static method
    my $classinput = $self.'::input';
    ${$classinput}->input(\$input);
  }
}

our $INPUT = \undef;
*Parse::Eyapp::Driver::YYInput = \&input;
sub input {
  my $self = shift;

  $self->line(1) if @_; # used as setter
  if (ref $self) { # instance method
    if (@_) {
      if (ref $_[0]) {
        $self->{INPUT} = shift;
      }
      else {
        my $input = shift;
        $self->{INPUT} = \$input;
      }
    }

    return $self->static_attribute('INPUT', @_,) unless defined($self->{INPUT}); # class/static method 
    return $self->{INPUT};
  }
  else { # class/static method
    return $self->static_attribute('INPUT', @_,); # class/static method 
  }
}
*YYInput = \&input;  # alias

# Opened file used to get the input
# static and instance method
our $INPUTFILE = \*STDIN;
sub YYInputFile {
  my $self = shift;

  if (ref($self)) { # object method
     my $file = shift;
     if ($file) { # setter
       $self->{INPUTFILE} = $file;
     }
    
    return $self->static_attribute('INPUTFILE', @_,) unless defined($self->{INPUTFILE}); # class/static method 
    return $self->{INPUTFILE};
  }
  else { # static
    return $self->static_attribute('INPUTFILE', @_,); # class/static method 
  }
}


our $PROMPT;
sub YYPrompt {
  my $self = shift;

  if (ref($self)) { # object method
     my $prompt = shift;
     if ($prompt) { # setter
       $self->{PROMPT} = $prompt;
     }
    
    return $self->static_attribute('PROMPT', @_,) unless defined($self->{PROMPT}); # class/static method 
    return $self->{PROMPT};
  }
  else { # static
    return $self->static_attribute('PROMPT', @_,); # class/static method 
  }
}

# args: parser, debug and optionally the input or a reference to the input
sub Run {
  my ($self) = shift;
  my $yydebug = shift;
  
  if (defined($_[0])) {
    if (ref($_[0])) { # if arg is a reference
      $self->input(shift());
    }
    else { # arg isn't a ref: make a copy
      my $x = shift();
      $self->input(\$x);
    }
  }
  croak "Provide some input for parsing" unless ($self->input && defined(${$self->input()}));
  return $self->YYParse( 
    #yylex => $self->lexer(), 
    #yyerror => $self->error(),
    yydebug => $yydebug, # 0xF
  );
}
*Parse::Eyapp::Driver::YYRun = \&run;

# args: class, prompt, file, optionally input (ref or not)
# return the abstract syntax tree (or whatever was returned by the parser)
*Parse::Eyapp::Driver::YYMain = \&main;
sub main {
  my $package = shift;
  my $prompt = shift;

  my $debug = 0;
  my $file = '';
  my $showtree = 0;
  my $TERMINALinfo;
  my $help;
  my $slurp;
  my $inputfromfile = 1;
  my $commandinput = '';
  my $quotedcommandinput = '';
  my $yaml = 0;
  my $dot = 0;

  my $result = GetOptions (
    "debug!"         => \$debug,         # sets yydebug on
    "file=s"         => \$file,          # read input from that file
    "commandinput=s" => \$commandinput,  # read input from command line arg
    "tree!"          => \$showtree,      # prints $tree->str
    "info"           => \$TERMINALinfo,  # prints $tree->str and provides default TERMINAL::info
    "help"           => \$help,          # shows SYNOPSIS section from the script pod
    "slurp!"         => \$slurp,         # read until EOF or CR is reached
    "argfile!"       => \$inputfromfile, # take input string from @_
    "yaml"           => \$yaml,          # dumps YAML for $tree: YAML must be installed
    "dot=s"          => \$dot,          # dumps YAML for $tree: YAML must be installed
    "margin=i"       => \$Parse::Eyapp::Node::INDENT,      
  );

  $package->_help() if $help;

  $debug = 0x1F if $debug;
  $file = shift if !$file && @ARGV; # file is taken from the @ARGV unless already defined
  $slurp = "\n" if defined($slurp);

  my $parser = $package->new();
  $parser->YYPrompt($prompt) if defined($prompt);

  if ($commandinput) {
    $parser->input(\$commandinput);
  }
  elsif ($inputfromfile) {
    $parser->slurp_file( $file, $slurp);
  }
  else { # input must be a string argument
    croak "No input provided for parsing! " unless defined($_[0]);
    if (ref($_[0])) {
      $parser->input(shift());
    }
    else {
      my $x = shift();
      $parser->input(\$x);
    }
  }

  if (defined($TERMINALinfo)) {
    my $prefix = ($parser->YYPrefix || '');
    no strict 'refs';
    *{$prefix.'TERMINAL::info'} = sub { 
      (ref($_[0]->attr) eq 'ARRAY')? $_[0]->attr->[0] : $_[0]->attr 
    };
  }

  my $tree = $parser->Run( $debug, @_ );

  if (my $ne = $parser->YYNberr > 0) {
    print "There were $ne errors during parsing\n";
    return undef;
  }
  else {
    if ($showtree) {
      if ($tree && blessed $tree && $tree->isa('Parse::Eyapp::Node')) {

          print $tree->str()."\n";
      }
      elsif ($tree && ref $tree) {
        require Data::Dumper;
        print Data::Dumper::Dumper($tree)."\n";
      }
      elsif (defined($tree)) {
        print "$tree\n";
      }
    }
    if ($yaml && ref($tree)) {
      eval {
        require YAML;
      };
      if ($@) {
        print "You must install 'YAML' to use this option\n";
      }
      else {
        YAML->import;
        print Dump($tree);
      }
    }
    if ($dot && blessed($tree)) {
      my ($sfile, $extension) = $dot =~ /^(.*)\.([^.]*)$/;
      $extension = 'png' unless (defined($extension) and $tree->can($extension));
      ($sfile) = $file =~ m{(.*[^.])} if !defined($sfile) and defined($file);
      $tree->$extension($sfile);
    }

    return $tree
  }
}

sub _help {
  my $package = shift;

  print << 'AYUDA';
Available options:
    --debug                    sets yydebug on
    --nodebug                  sets yydebug off
    --file filepath            read input from filepath
    --commandinput string      read input from string
    --tree                     prints $tree->str
    --notree                   does not print $tree->str
    --info                     When printing $tree->str shows the value of TERMINALs
    --help                     shows this help
    --slurp                    read until EOF reached
    --noslurp                  read until CR is reached
    --argfile                  main() will take the input string from its @_
    --noargfile                main() will not take the input string from its @_
    --yaml                     dumps YAML for $tree: YAML module must be installed
    --margin=i                 controls the indentation of $tree->str (i.e. $Parse::Eyapp::Node::INDENT)      
    --dot format               produces a .dot and .format file (png,jpg,bmp, etc.)
AYUDA

  $package->help() if ($package & $package->can("help"));

  exit(0);
}

# Generic error handler
# Convention adopted: if the attribute of a token is an object
# assume it has 'line' and 'str' methods. Otherwise, if it
# is an array, follows the convention [ str, line, ...]
# otherwise is just an string representing the value of the token
sub _Error {
  my $parser = shift;

  my $yydata = $parser->YYData;

    exists $yydata->{ERRMSG}
  and do {
      warn $yydata->{ERRMSG};
      delete $yydata->{ERRMSG};
      return;
  };

  my ($attr)=$parser->YYCurval;

  my $stoken = '';

  if (blessed($attr) && $attr->can('str')) {
     $stoken = " near '".$attr->str."'"
  }
  elsif (ref($attr) eq 'ARRAY') {
    $stoken = " near '".$attr->[0]."'";
  }
  else {
    if ($attr) {
      $stoken = " near '$attr'";
    }
    else {
      $stoken = " near end of input";
    }
  }

  my @expected = map { ($_ ne '')? "'$_'" : q{'end of input'}} $parser->YYExpect();
  my $expected = '';
  if (@expected) {
    $expected = (@expected >1) ? "Expected one of these terminals: @expected" 
                              : "Expected terminal: @expected"
  }

  my $tline = '';
  if (blessed($attr) && $attr->can('line')) {
    $tline = " (line number ".$attr->line.")" 
  }
  elsif (ref($attr) eq 'ARRAY') {
    $tline = " (line number ".$attr->[1].")";
  }
  else {
    # May be the parser object knows the line number ?
    my $lineno = $parser->line;
    $tline = " (line number $lineno)" if $lineno > 1;
  }

  local $" = ', ';
  warn << "ERRMSG";

Syntax error$stoken$tline. 
$expected
ERRMSG
};

################ end TailSupport #####################

sub _DBLoad {

  #Already loaded ?
  __PACKAGE__->can('_DBParse') and return;
  
  my($fname)=__FILE__;
  my(@drv);
  local $/ = "\n";
  if (open(DRV,"<$fname")) {
    local $_;
    while(<DRV>) {
       #/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/ and do {
       /^my\s+\$lex;##!!##$/ .. /^\s*}\s*#\s*_Parse\s*$/ and do {
          s/^#DBG>//;
          push(@drv,$_);
      }
    }
    close(DRV);

    $drv[1]=~s/_P/_DBP/;
    eval join('',@drv);
  }
  else {
    # TODO: debugging for standalone modules isn't supported yet
    *Parse::Eyapp::Driver::_DBParse = \&_Parse;
  }
}

### Receives an  index for the parsing stack: -1 is the top
### Returns the symbol associated with the state $index
sub YYSymbol {
  my $self = shift;
  my $index = shift;
  
  return $self->{STACK}[$index][2];
}

# # YYSymbolStack(0,-k) string with symbols from 0 to last-k
# # YYSymbolStack(-k-2,-k) string with symbols from last-k-2 to last-k
# # YYSymbolStack(-k-2,-k, filter) string with symbols from last-k-2 to last-k that match with filter
# # YYSymbolStack('SYMBOL',-k, filter) string with symbols from the last occurrence of SYMBOL to last-k
# #                                    where filter can be code, regexp or string
# sub YYSymbolStack {
#   my $self = shift;
#   my ($a, $b, $filter) = @_;
#   
#   # $b must be negative
#   croak "Error: Second index in YYSymbolStack must be negative\n" unless $b < 0;
# 
#   my $stack = $self->{STACK};
#   my $bottom = -@{$stack};
#   unless (looks_like_number($a)) {
#     # $a is a string: search from the top to the bottom for $a. Return empty list if not found
#     # $b must be a negative number
#     # $b must be a negative number
#     my $p = $b;
#     while ($p >= $bottom) {
#       last if (defined($stack->[$p][2]) && ($stack->[$p][2] eq $a));
#       $p--;
#     }
#     return () if $p < $bottom;
#     $a = $p;
#   }
#   # If positive, $a is an offset from the bottom of the stack 
#   $a = $bottom+$a if $a >= 0;
#   
#   my @a = map { $self->YYSymbol($_) or '' } $a..$b;
#    
#   return @a                          unless defined $filter;          # no filter
#   return (grep { $filter->{$_} } @a) if reftype($filter) && (reftype($filter) eq 'CODE');   # sub
#   return (grep  /$filter/, @a)       if reftype($filter) && (reftype($filter) eq 'SCALAR'); # regexp
#   return (grep { $_ eq $filter } @a);                                  # string
# }

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
my $lex;##!!##
sub _Parse {
    my($self)=shift;

  #my $lex = $self->{LEX};

  my($rules,$states,$error)
     = @$self{ 'RULES', 'STATES', 'ERROR' };
  my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

  my %conflictiveStates = %{$self->{STATECONFLICT}};
#DBG> my($debug)=$$self{DEBUG};
#DBG> my($dbgerror)=0;

#DBG> my($ShowCurToken) = sub {
#DBG>   my($tok)='>';
#DBG>   for (split('',$$token)) {
#DBG>     $tok.=    (ord($_) < 32 or ord($_) > 126)
#DBG>         ? sprintf('<%02X>',ord($_))
#DBG>         : $_;
#DBG>   }
#DBG>   $tok.='<';
#DBG> };

  $$errstatus=0;
  $$nberror=0;
  ($$token,$$value)=(undef,undef);
  @$stack=( [ 0, undef, ] );
#DBG>   push(@{$stack->[-1]}, undef);
  #@$stack=( [ 0, undef, undef ] );
  $$check='';

    while(1) {
        my($actions,$act,$stateno);

        $self->{POS} = pos(${$self->input()});
        $stateno=$$stack[-1][0];
        if (exists($conflictiveStates{$stateno})) {
          #warn "Conflictive state $stateno managed by conflict handler '$conflictiveStates{$stateno}{name}'\n" 
          for my $h (@{$conflictiveStates{$stateno}}) {
            $self->{CURRENT_LHS} = $h->{name};
            $h->{codeh}($self);
          }
        }

        # check if the state is a conflictive one,
        # if so, execute its conflict handlers
        $actions=$$states[$stateno];

#DBG> print STDERR ('-' x 40),"\n";
#DBG>   $debug & 0x2
#DBG> and print STDERR "In state $stateno:\n";
#DBG>   $debug & 0x08
#DBG> and print STDERR "Stack: ".
#DBG>          join('->',map { defined($$_[2])? "'$$_[2]'->".$$_[0] : $$_[0] } @$stack).
#DBG>          "\n";


        if  (exists($$actions{ACTIONS})) {

        defined($$token)
            or  do {
        ($$token,$$value)=$self->{LEX}->($self); # original line
        #($$token,$$value)=$self->$lex;   # to make it a method call
        #($$token,$$value) = $self->{LEX}->($self); # sensitive to the lexer changes
#DBG>       $debug & 0x01
#DBG>     and do { 
#DBG>       print STDERR "Need token. Got ".&$ShowCurToken."\n";
#DBG>     };
      };

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>     $debug & 0x01
#DBG>   and print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>       $debug & 0x04
#DBG>     and print STDERR "Shift and go to state $act.\n";

          $$errstatus
        and do {
          --$$errstatus;

#DBG>         $debug & 0x10
#DBG>       and $dbgerror
#DBG>       and $$errstatus == 0
#DBG>       and do {
#DBG>         print STDERR "**End of Error recovery.\n";
#DBG>         $dbgerror=0;
#DBG>       };
        };


        push(@$stack,[ $act, $$value ]);
#DBG>   push(@{$stack->[-1]},$$token);

          defined($$token) and ($$token ne '') #Don't eat the eof
              and $$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>     $debug & 0x04
#DBG>   and $act
#DBG>   #and  print STDERR "Reduce using rule ".-$act." ($lhs,$len): "; # old Parse::Yapp line
#DBG>   and do { my @rhs = @{$self->{GRAMMAR}->[-$act]->[2]};
#DBG>            @rhs = ( '/* empty */' ) unless @rhs;
#DBG>            my $rhs = "@rhs";
#DBG>            $rhs = substr($rhs, 0, 30).'...' if length($rhs) > 30; # chomp if too large
#DBG>            print STDERR "Reduce using rule ".-$act." ($lhs --> $rhs): "; 
#DBG>          };

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $self->{CURRENT_LHS} = $lhs;
            $self->{CURRENT_RULE} = -$act; # count the super-rule?
            $semval = $code ? $self->$code( @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>     $debug & 0x04
#DBG>   and print STDERR "Accept.\n";

        return($semval);
      };

                $$check eq 'ABORT'
            and do {

#DBG>     $debug & 0x04
#DBG>   and print STDERR "Abort.\n";

        return(undef);

      };

#DBG>     $debug & 0x04
#DBG>   and print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>       $debug & 0x04
#DBG>     and print STDERR 
#DBG>           "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>       $debug & 0x10
#DBG>     and $dbgerror
#DBG>     and $$errstatus == 0
#DBG>     and do {
#DBG>       print STDERR "**End of Error recovery.\n";
#DBG>       $dbgerror=0;
#DBG>     };

          push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval, ]);
                     #[ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval, $lhs ]);
#DBG>     push(@{$stack->[-1]},$lhs);
                $$check='';
                $self->{CURRENT_LHS} = undef;
                next;
            };

#DBG>     $debug & 0x04
#DBG>   and print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>     $debug & 0x10
#DBG>   and do {
#DBG>     print STDERR "**Entering Error recovery.\n";
#DBG>     { 
#DBG>       local $" = ", "; 
#DBG>       my @expect = map { ">$_<" } $self->YYExpect();
#DBG>       print STDERR "Expecting one of: @expect\n";
#DBG>     };
#DBG>     ++$dbgerror;
#DBG>   };

            ++$$nberror;

        };

      $$errstatus == 3  #The next token is not valid: discard it
    and do {
        $$token eq '' # End of input: no hope
      and do {
#DBG>       $debug & 0x10
#DBG>     and print STDERR "**At eof: aborting.\n";
        return(undef);
      };

#DBG>     $debug & 0x10
#DBG>   and print STDERR "**Discard invalid token ".&$ShowCurToken.".\n";

      $$token=$$value=undef;
    };

        $$errstatus=3;

    while(    @$stack
        and (   not exists($$states[$$stack[-1][0]]{ACTIONS})
              or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
          or  $$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>     $debug & 0x10
#DBG>   and print STDERR "**Pop state $$stack[-1][0].\n";

      pop(@$stack);
    }

      @$stack
    or  do {

#DBG>     $debug & 0x10
#DBG>   and print STDERR "**No state left on stack: aborting.\n";

      return(undef);
    };

    #shift the error token

#DBG>     $debug & 0x10
#DBG>   and print STDERR "**Shift \$error token and go to state ".
#DBG>            $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>            ".\n";

    push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef, 'error' ]);

    }

    #never reached
  croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

*Parse::Eyapp::Driver::lexer = \&Parse::Eyapp::Driver::YYLexer;
sub YYLexer {
  my $self = shift;

  if (ref $self) { # instance method
    # The class attribute isn't changed, only the instance
    $self->{LEX} = shift if @_;

    return $self->static_attribute('LEX', @_,) unless defined($self->{LEX}); # class/static method 
    return $self->{LEX};
  }
  else {
    return $self->static_attribute('LEX', @_,);
  }
}


1;


MODULE_Parse_Eyapp_Driver
    }; # Unless Parse::Eyapp::Driver was loaded
  } ########### End of BEGIN { load perl-local/lib/perl5/site_perl//5.16.2/Parse/Eyapp/Driver.pm }

  # Loading Parse::Eyapp::Node
  BEGIN {
    unless (Parse::Eyapp::Node->can('m')) {
      eval << 'MODULE_Parse_Eyapp_Node'
# (c) Parse::Eyapp Copyright 2006-2008 Casiano Rodriguez-Leon, all rights reserved.
package Parse::Eyapp::Node;
use strict;
use Carp;
no warnings 'recursion';use List::Util qw(first);
use Data::Dumper;

our $FILENAME=__FILE__;

sub firstval(&@) {
  my $handler = shift;
  
  return (grep { $handler->($_) } @_)[0]
}

sub lastval(&@) {
  my $handler = shift;
  
  return (grep { $handler->($_) } @_)[-1]
}

####################################################################
# Usage      : 
# line: %name PROG
#        exp <%name EXP + ';'>
#                 { @{$lhs->{t}} = map { $_->{t}} ($lhs->child(0)->children()); }
# ;
# Returns    : The array of children of the node. When the tree is a
#              translation scheme the CODE references are also included
# Parameters : the node (method)
# See Also   : Children

sub children {
  my $self = CORE::shift;
  
  return () unless UNIVERSAL::can($self, 'children');
  @{$self->{children}} = @_ if @_;
  @{$self->{children}}
}

####################################################################
# Usage      :  line: %name PROG
#                        (exp) <%name EXP + ';'>
#                          { @{$lhs->{t}} = map { $_->{t}} ($_[1]->Children()); }
#
# Returns    : The true children of the node, excluding CODE CHILDREN
# Parameters : The Node object

sub Children {
  my $self = CORE::shift;
  
  return () unless UNIVERSAL::can($self, 'children');

  @{$self->{children}} = @_ if @_;
  grep { !UNIVERSAL::isa($_, 'CODE') } @{$self->{children}}
}

####################################################################
# Returns    : Last non CODE child
# Parameters : the node object

sub Last_child {
  my $self = CORE::shift;

  return unless UNIVERSAL::can($self, 'children') and @{$self->{children}};
  my $i = -1;
  $i-- while defined($self->{children}->[$i]) and UNIVERSAL::isa($self->{children}->[$i], 'CODE');
  return  $self->{children}->[$i];
}

sub last_child {
  my $self = CORE::shift;

  return unless UNIVERSAL::can($self, 'children') and @{$self->{children}};
  ${$self->{children}}[-1];
}

####################################################################
# Usage      :  $node->child($i)
#  my $transform = Parse::Eyapp::Treeregexp->new( STRING => q{
#     commutative_add: PLUS($x, ., $y, .)
#       => { my $t = $x; $_[0]->child(0, $y); $_[0]->child(2, $t)}
#  }
# Purpose    : Setter-getter to modify a specific child of a node
# Returns    : Child with index $i. Returns undef if the child does not exists
# Parameters : Method: the node and the index of the child. The new value is used 
#              as a setter.
# Throws     : Croaks if the index parameter is not provided
sub child {
  my ($self, $index, $value) = @_;
  
  #croak "$self is not a Parse::Eyapp::Node" unless $self->isa('Parse::Eyapp::Node');
  return undef unless  UNIVERSAL::can($self, 'child');
  croak "Index not provided" unless defined($index);
  $self->{children}[$index] = $value if defined($value);
  $self->{children}[$index];
}

sub descendant {
  my $self = shift;
  my $coord = shift;

  my @pos = split /\./, $coord;
  my $t = $self;
  my $x = shift(@pos); # discard the first empty dot
  for (@pos) {
      croak "Error computing descendant: $_ is not a number\n" 
    unless m{\d+} and $_ < $t->children;
    $t = $t->child($_);
  }
  return $t;
}

####################################################################
# Usage      : $node->s(@transformationlist);
# Example    : The following example simplifies arithmetic expressions
# using method "s":
# > cat Timeszero.trg
# /* Operator "and" has higher priority than comma "," */
# whatever_times_zero: TIMES(@b, NUM($x) and { $x->{attr} == 0 }) => { $_[0] = $NUM }
#
# > treereg Timeszero
# > cat arrays.pl
#  !/usr/bin/perl -w
#  use strict;
#  use Rule6;
#  use Parse::Eyapp::Treeregexp;
#  use Timeszero;
#
#  my $parser = new Rule6();
#  my $t = $parser->Run;
#  $t->s(@Timeszero::all);
#
#
# Returns    : Nothing
# Parameters : The object (is a method) and the list of transformations to apply.
#              The list may be a list of Parse::Eyapp:YATW objects and/or CODE
#              references
# Throws     : No exceptions
# Comments   : The set of transformations is repeatedly applied to the node
#              until there are no changes.
#              The function may hang if the set of transformations
#              matches forever.
# See Also   : The "s" method for Parse::Eyapp::YATW objects 
#              (i.e. transformation objects)

sub s {
  my @patterns = @_[1..$#_];

  # Make them Parse::Eyapp:YATW objects if they are CODE references
  @patterns = map { ref($_) eq 'CODE'? 
                      Parse::Eyapp::YATW->new(
                        PATTERN => $_,
                        #PATTERN_ARGS => [],
                      )
                      :
                      $_
                  } 
                  @patterns;
  my $changes; 
  do { 
    $changes = 0;
    foreach (@patterns) {
      $_->{CHANGES} = 0;
      $_->s($_[0]);
      $changes += $_->{CHANGES};
    }
  } while ($changes);
}


####################################################################
# Usage      : ????
# Purpose    : bud = Bottom Up Decoration: Decorates the tree with flowers :-)
#              The purpose is to decorate the AST with attributes during
#              the context-dependent analysis, mainly type-checking.
# Returns    : ????
# Parameters : The transformations.
# Throws     : no exceptions
# Comments   : The tree is traversed bottom-up. The set of
#              transformations is applied to each node in the order
#              supplied by the user. As soon as one succeeds
#              no more transformations are applied.
# See Also   : n/a
# To Do      : Avoid closure. Save @patterns inside the object
{
  my @patterns;

  sub bud {
    @patterns = @_[1..$#_];

    @patterns = map { ref($_) eq 'CODE'? 
                        Parse::Eyapp::YATW->new(
                          PATTERN => $_,
                          #PATTERN_ARGS => [],
                        )
                        :
                        $_
                    } 
                    @patterns;
    _bud($_[0], undef, undef);
  }

  sub _bud {
    my $node = $_[0];
    my $index = $_[2];

      # Is an odd leaf. Not actually a Parse::Eyapp::Node. Decorate it and leave
      if (!ref($node) or !UNIVERSAL::can($node, "children"))  {
        for my $p (@patterns) {
          return if $p->pattern->(
            $_[0],  # Node being visited  
            $_[1],  # Father of this node
            $index, # Index of this node in @Father->children
            $p,  # The YATW pattern object   
          );
        }
      };

      # Recursively decorate subtrees
      my $i = 0;
      for (@{$node->{children}}) {
        $_->_bud($_, $_[0], $i);
        $i++;
      }

      # Decorate the node
      #Change YATW object to be the  first argument?
      for my $p (@patterns) {
        return if $p->pattern->($_[0], $_[1], $index, $p); 
      }
  }
} # closure for @patterns

####################################################################
# Usage      : 
# @t = Parse::Eyapp::Node->new( q{TIMES(NUM(TERMINAL), NUM(TERMINAL))}, 
#      sub { 
#        our ($TIMES, @NUM, @TERMINAL);
#        $TIMES->{type}       = "binary operation"; 
#        $NUM[0]->{type}      = "int"; 
#        $NUM[1]->{type}      = "float"; 
#        $TERMINAL[1]->{attr} = 3.5; 
#      },
#    );
# Purpose    : Multi-Constructor
# Returns    : Array of pointers to the objects created
#              in scalar context a pointer to the first node
# Parameters : The class plus the string description and attribute handler

{

my %cache;

  sub m_bless {

    my $key = join "",@_;
    my $class = shift;
    return $cache{$key} if exists $cache{$key};

    my $b = bless { children => \@_}, $class;
    $cache{$key} = $b;

    return $b;
  }
}

sub _bless {
  my $class = shift;

  my $b = bless { children => \@_ }, $class;
  return $b;
}

sub hexpand {
  my $class = CORE::shift;

  my $handler = CORE::pop if ref($_[-1]) eq 'CODE';
  my $n = m_bless(@_);

  my $newnodeclass = CORE::shift;

  no strict 'refs';
  push @{$newnodeclass."::ISA"}, 'Parse::Eyapp::Node' unless $newnodeclass->isa('Parse::Eyapp::Node');

  if (defined($handler) and UNIVERSAL::isa($handler, "CODE")) {
    $handler->($n);
  }

  $n;
}

sub hnew {
  my $blesser = \&m_bless;

  return _new($blesser, @_);
}

# Regexp for a full Perl identifier
sub _new {
  my $blesser = CORE::shift;
  my $class = CORE::shift;
  local $_ = CORE::shift; # string: tree description
  my $handler = CORE::shift if ref($_[0]) eq 'CODE';


  my %classes;
  my $b;
  #TODO: Shall I receive a prefix?

  my (@stack, @index, @results, %results, @place, $open);
  #skip white spaces
  s{\A\s+}{};
  while ($_) {
    # If is a leaf is followed by parenthesis or comma or an ID
    s{\A([A-Za-z_][A-Za-z0-9_:]*)\s*([),])} 
     {$1()$2} # ... then add an empty pair of parenthesis
      and do { 
        next; 
       };

    # If is a leaf is followed by an ID
    s{\A([A-Za-z_][A-Za-z0-9_:]*)\s+([A-Za-z_])} 
     {$1()$2} # ... then add an empty pair of parenthesis
      and do { 
        next; 
       };

    # If is a leaf at the end
    s{\A([A-Za-z_][A-Za-z0-9_:]*)\s*$} 
     {$1()} # ... then add an empty pair of parenthesis
      and do { 
        $classes{$1} = 1;
        next; 
       };

    # Is an identifier
    s{\A([A-Za-z_][A-Za-z0-9_:]*)}{} 
      and do { 
        $classes{$1} = 1;
        CORE::push @stack, $1; 
        next; 
      };

    # Open parenthesis: mark the position for when parenthesis closes
    s{\A[(]}{} 
      and do { 
        my $pos = scalar(@stack);
        CORE::push @index, $pos; 
        $place[$pos] = $open++;

        # Warning! I don't know what I am doing
        next;
      };

    # Skip commas
    s{\A,}{} and next; 

    # Closing parenthesis: time to build a node
    s{\A[)]}{} and do { 
        croak "Syntax error! Closing parenthesis has no left partner!" unless @index;
        my $begin = pop @index; # check if empty!
        my @children = splice(@stack, $begin);
        my $class = pop @stack;
        croak "Syntax error! Any couple of parenthesis must be preceded by an identifier"
          unless (defined($class) and $class =~ m{^[a-zA-Z_][\w:]*$});

        $b = $blesser->($class, @children);

        CORE::push @stack, $b;
        $results[$place[$begin]] = $b;
        CORE::push @{$results{$class}}, $b;
        next; 
    }; 

    last unless $_;

    #skip white spaces
    croak "Error building Parse::Eyapp::Node tree at '$_'." unless s{\A\s+}{};
  } # while
  croak "Syntax error! Open parenthesis has no right partner!" if @index;
  { 
    no strict 'refs';
    for (keys(%classes)) {
      push @{$_."::ISA"}, 'Parse::Eyapp::Node' unless $_->isa('Parse::Eyapp::Node');
    }
  }
  if (defined($handler) and UNIVERSAL::isa($handler, "CODE")) {
    $handler->(@results);
  }
  return wantarray? @results : $b;
}

sub new {
  my $blesser = \&_bless;

  _new($blesser, @_);
}

## Used by _subtree_list
#sub compute_hierarchy {
#  my @results = @{shift()};
#
#  # Compute the hierarchy
#  my $b;
#  my @r = @results;
#  while (@results) {
#    $b = pop @results;
#    my $d = $b->{depth};
#    my $f = lastval { $_->{depth} < $d} @results;
#    
#    $b->{father} = $f;
#    $b->{children} = [];
#    unshift @{$f->{children}}, $b;
#  }
#  $_->{father} = undef for @results;
#  bless $_, "Parse::Eyapp::Node::Match" for @r;
#  return  @r;
#}

# Matches

sub m {
  my $self = shift;
  my @patterns = @_ or croak "Expected a pattern!";
  croak "Error in method m of Parse::Eyapp::Node. Expected Parse::Eyapp:YATW patterns"
    unless $a = first { !UNIVERSAL::isa($_, "Parse::Eyapp:YATW") } @_;

  # array context: return all matches
  local $a = 0;
  my %index = map { ("$_", $a++) } @patterns;
  my @stack = (
    Parse::Eyapp::Node::Match->new( 
       node => $self, 
       depth => 0,  
       dewey => "", 
       patterns =>[] 
    ) 
  );
  my @results;
  do {
    my $mn = CORE::shift(@stack);
    my %n = %$mn;

    # See what patterns do match the current $node
    for my $pattern (@patterns) {
      push @{$mn->{patterns}}, $index{$pattern} if $pattern->{PATTERN}($n{node});
    } 
    my $dewey = $n{dewey};
    if (@{$mn->{patterns}}) {
      $mn->{family} = \@patterns;

      # Is at this time that I have to compute the father
      my $f = lastval { $dewey =~ m{^$_->{dewey}}} @results;
      $mn->{father} = $f;
      # ... and children
      push @{$f->{children}}, $mn if defined($f);
      CORE::push @results, $mn;
    }
    my $childdepth = $n{depth}+1;
    my $k = -1;
    CORE::unshift @stack, 
          map 
            { 
              $k++; 
              Parse::Eyapp::Node::Match->new(
                node => $_, 
                depth => $childdepth, 
                dewey => "$dewey.$k", 
                patterns => [] 
              ) 
            } $n{node}->children();
  } while (@stack);

  wantarray? @results : $results[0];
}

#sub _subtree_scalar {
#  # scalar context: return iterator
#  my $self = CORE::shift;
#  my @patterns = @_ or croak "Expected a pattern!";
#
#  # %index gives the index of $p in @patterns
#  local $a = 0;
#  my %index = map { ("$_", $a++) } @patterns;
#
#  my @stack = ();
#  my $mn = { node => $self, depth => 0, patterns =>[] };
#  my @results = ();
#
#  return sub {
#     do {
#       # See if current $node matches some patterns
#       my $d = $mn->{depth};
#       my $childdepth = $d+1;
#       # See what patterns do match the current $node
#       for my $pattern (@patterns) {
#         push @{$mn->{patterns}}, $index{$pattern} if $pattern->{PATTERN}($mn->{node});
#       } 
#
#       if (@{$mn->{patterns}}) { # matched
#         CORE::push @results, $mn;
#
#         # Compute the hierarchy
#         my $f = lastval { $_->{depth} < $d} @results;
#         $mn->{father} = $f;
#         $mn->{children} = [];
#         $mn->{family} = \@patterns;
#         unshift @{$f->{children}}, $mn if defined($f);
#         bless $mn, "Parse::Eyapp::Node::Match";
#
#         # push children in the stack
#         CORE::unshift @stack, 
#                   map { { node => $_, depth => $childdepth, patterns => [] } } 
#                                                       $mn->{node}->children();
#         $mn = CORE::shift(@stack);
#         return $results[-1];
#       }
#       # didn't match: push children in the stack
#       CORE::unshift @stack, 
#                  map { { node => $_, depth => $childdepth, patterns => [] } } 
#                                                      $mn->{node}->children();
#       $mn = CORE::shift(@stack);
#     } while ($mn); # May be the stack is empty now, but if $mn then there is a node to process
#     # reset iterator
#     my @stack = ();
#     my $mn = { node => $self, depth => 0, patterns =>[] };
#     return undef;
#   };
#}

# Factorize this!!!!!!!!!!!!!!
#sub m {
#  goto &_subtree_list if (wantarray()); 
#  goto &_subtree_scalar;
#}

####################################################################
# Usage      :   $BLOCK->delete($ASSIGN)
#                $BLOCK->delete(2)
# Purpose    : deletes the specified child of the node
# Returns    : The deleted child
# Parameters : The object plus the index or pointer to the child to be deleted
# Throws     : If the object can't do children or has no children
# See Also   : n/a

sub delete {
  my $self = CORE::shift; # The tree object
  my $child = CORE::shift; # index or pointer

  croak "Parse::Eyapp::Node::delete error, node:\n"
        .Parse::Eyapp::Node::str($self)."\ndoes not have children" 
    unless UNIVERSAL::can($self, 'children') and ($self->children()>0);
  if (ref($child)) {
    my $i = 0;
    for ($self->children()) {
      last if $_ == $child;
      $i++;
    }
    if ($i == $self->children()) {
      warn "Parse::Eyapp::Node::delete warning: node:\n".Parse::Eyapp::Node::str($self)
           ."\ndoes not have a child like:\n"
           .Parse::Eyapp::Node::str($child)
           ."\nThe node was not deleted!\n";
      return $child;
    }
    splice(@{$self->{children}}, $i, 1);
    return $child;
  }
  my $numchildren = $self->children();
  croak "Parse::Eyapp::Node::delete error: expected an index between 0 and ".
        ($numchildren-1).". Got $child" unless ($child =~ /\d+/ and $child < $numchildren);
  splice(@{$self->{children}}, $child, 1);
  return $child;
}

####################################################################
# Usage      : $BLOCK->shift
# Purpose    : deletes the first child of the node
# Returns    : The deleted child
# Parameters : The object 
# Throws     : If the object can't do children 
# See Also   : n/a

sub shift {
  my $self = CORE::shift; # The tree object

  croak "Parse::Eyapp::Node::shift error, node:\n"
       .Parse::Eyapp::Node->str($self)."\ndoes not have children" 
    unless UNIVERSAL::can($self, 'children');

  return CORE::shift(@{$self->{children}});
}

sub unshift {
  my $self = CORE::shift; # The tree object
  my $node = CORE::shift; # node to insert

  CORE::unshift @{$self->{children}}, $node;
}

sub push {
  my $self = CORE::shift; # The tree object
  #my $node = CORE::shift; # node to insert

  #CORE::push @{$self->{children}}, $node;
  CORE::push @{$self->{children}}, @_;
}

sub insert_before {
  my $self = CORE::shift; # The tree object
  my $child = CORE::shift; # index or pointer
  my $node = CORE::shift; # node to insert

  croak "Parse::Eyapp::Node::insert_before error, node:\n"
        .Parse::Eyapp::Node::str($self)."\ndoes not have children" 
    unless UNIVERSAL::can($self, 'children') and ($self->children()>0);

  if (ref($child)) {
    my $i = 0;
    for ($self->children()) {
      last if $_ == $child;
      $i++;
    }
    if ($i == $self->children()) {
      warn "Parse::Eyapp::Node::insert_before warning: node:\n"
           .Parse::Eyapp::Node::str($self)
           ."\ndoes not have a child like:\n"
           .Parse::Eyapp::Node::str($child)."\nThe node was not inserted!\n";
      return $child;
    }
    splice(@{$self->{children}}, $i, 0, $node);
    return $node;
  }
  my $numchildren = $self->children();
  croak "Parse::Eyapp::Node::insert_before error: expected an index between 0 and ".
        ($numchildren-1).". Got $child" unless ($child =~ /\d+/ and $child < $numchildren);
  splice(@{$self->{children}}, $child, 0, $node);
  return $child;
}

sub insert_after {
  my $self = CORE::shift; # The tree object
  my $child = CORE::shift; # index or pointer
  my $node = CORE::shift; # node to insert

  croak "Parse::Eyapp::Node::insert_after error, node:\n"
        .Parse::Eyapp::Node::str($self)."\ndoes not have children" 
    unless UNIVERSAL::can($self, 'children') and ($self->children()>0);

  if (ref($child)) {
    my $i = 0;
    for ($self->children()) {
      last if $_ == $child;
      $i++;
    }
    if ($i == $self->children()) {
      warn "Parse::Eyapp::Node::insert_after warning: node:\n"
           .Parse::Eyapp::Node::str($self).
           "\ndoes not have a child like:\n"
           .Parse::Eyapp::Node::str($child)."\nThe node was not inserted!\n";
      return $child;
    }
    splice(@{$self->{children}}, $i+1, 0, $node);
    return $node;
  }
  my $numchildren = $self->children();
  croak "Parse::Eyapp::Node::insert_after error: expected an index between 0 and ".
        ($numchildren-1).". Got $child" unless ($child =~ /\d+/ and $child < $numchildren);
  splice(@{$self->{children}}, $child+1, 0, $node);
  return $child;
}

{ # $match closure

  my $match;

  sub clean_tree {
    $match = pop;
    croak "clean tree: a node and code reference expected" unless (ref($match) eq 'CODE') and (@_ > 0);
    $_[0]->_clean_tree();
  }

  sub _clean_tree {
    my @children;
    
    for ($_[0]->children()) {
      next if (!defined($_) or $match->($_));
      
      $_->_clean_tree();
      CORE::push @children, $_;
    }
    $_[0]->{children} = \@children; # Bad code
  }
} # $match closure

####################################################################
# Usage      : $t->str 
# Returns    : Returns a string describing the Parse::Eyapp::Node as a term
#              i.e., s.t. like: 'PROGRAM(FUNCTION(RETURN(TERMINAL,VAR(TERMINAL))))'
our @PREFIXES = qw(Parse::Eyapp::Node::);
our $INDENT = 0; # -1 new 0 = compact, 1 = indent, 2 = indent and include Types in closing parenthesis
our $STRSEP = ',';
our $DELIMITER = '[';
our $FOOTNOTE_HEADER = "\n---------------------------\n";
our $FOOTNOTE_SEP = ")\n";
our $FOOTNOTE_LEFT = '^{';
our $FOOTNOTE_RIGHT = '}';
our $LINESEP = 4;
our $CLASS_HANDLER = sub { type($_[0]) }; # What to print to identify the node

my %match_del = (
  '[' => ']',
  '{' => '}',
  '(' => ')',
  '<' => '>'
);

my $pair;
my $footnotes = '';
my $footnote_label;

sub str {

  my @terms;

  # Consume arg only if called as a class method Parse::Eyap::Node->str($node1, $node2, ...)
  CORE::shift unless ref($_[0]);

  for (@_) {
    $footnote_label = 0;
    $footnotes = '';
    # Set delimiters for semantic values
    if (defined($DELIMITER) and exists($match_del{$DELIMITER})) {
      $pair = $match_del{$DELIMITER};
    }
    else {
      $DELIMITER = $pair = '';
    }
    CORE::push @terms,  _str($_).$footnotes;
  }
  return wantarray? @terms : $terms[0];
}  

sub _str {
  my $self = CORE::shift;          # root of the subtree
  my $indent = (CORE::shift or 0); # current depth in spaces " "

  my @children = Parse::Eyapp::Node::children($self);
  my @t;

  my $res;
  my $fn = $footnote_label;
  if ($INDENT >= 0 && UNIVERSAL::can($self, 'footnote')) {
    $res = $self->footnote; 
    $footnotes .= $FOOTNOTE_HEADER.$footnote_label++.$FOOTNOTE_SEP.$res if $res;
  }

  # recursively visit nodes
  for (@children) {
    CORE::push @t, Parse::Eyapp::Node::_str($_, $indent+2) if defined($_);
  }
  local $" = $STRSEP;
  my $class = $CLASS_HANDLER->($self);
  $class =~ s/^$_// for @PREFIXES; 
  my $information;
  $information = $self->info if ($INDENT >= 0 && UNIVERSAL::can($self, 'info'));
  $class .= $DELIMITER.$information.$pair if defined($information);
  if ($INDENT >= 0 &&  $res) {
   $class .= $FOOTNOTE_LEFT.$fn.$FOOTNOTE_RIGHT;
  }

  if ($INDENT > 0) {
    my $w = " "x$indent;
    $class = "\n$w$class";
    $class .= "(@t\n$w)" if @children;
    $class .= " # ".$CLASS_HANDLER->($self) if ($INDENT > 1) and ($class =~ tr/\n/\n/>$LINESEP);
  }
  else {
    $class .= "(@t)" if @children;
  }
  return $class;
}

sub _dot {
  my ($root, $number) = @_;

  my $type = $root->type();

  my $information;
  $information = $root->info if ($INDENT >= 0 && $root->can('info'));
  my $class = $CLASS_HANDLER->($root);
  $class = qq{$class<font color="red">$DELIMITER$information$pair</font>} if defined($information);

  my $dot = qq{  $number [label = <$class>];\n};

  my $k = 0;
  my @dots = map { $k++; $_->_dot("$number$k") }  $root->children;

  for($k = 1; $k <= $root->children; $k++) {;
    $dot .= qq{  $number -> $number$k;\n};
  }

  return $dot.join('',@dots);
}

sub dot {
  my $dot = $_[0]->_dot('0');
  return << "EOGRAPH";
digraph G {
ordering=out

$dot
}
EOGRAPH
}

sub fdot {
  my ($self, $file) = @_;

  if ($file) {
    $file .= '.dot' unless $file =~ /\.dot$/;
  }
  else {
    $file = $self->type().".dot";
  }
  open my $f, "> $file";
  print $f $self->dot();
  close($f);
}

BEGIN {
  my @dotFormats = qw{bmp canon cgimage cmap cmapx cmapx_np eps exr fig gd gd2 gif gv imap imap_np ismap jp2 jpe jpeg jpg pct pdf pict plain plain-ext png ps ps2 psd sgi svg svgz tga tif tiff tk vml vmlz vrml wbmp x11 xdot xlib};

  for my $format (@dotFormats) {
     
    no strict 'refs';
    *{'Parse::Eyapp::Node::'.$format} = sub { 
       my ($self, $file) = @_;
   
       $file = $self->type() unless defined($file);
   
       $self->fdot($file);
   
       $file =~ s/\.(dot|$format)$//;
       my $dotfile = "$file.dot";
       my $pngfile = "$file.$format";
       my $err = qx{dot -T$format $dotfile -o $pngfile 2>&1};
       return ($err, $?);
    }
  }
}

sub translation_scheme {
  my $self = CORE::shift; # root of the subtree
  my @children = $self->children();
  for (@children) {
    if (ref($_) eq 'CODE') {
      $_->($self, $self->Children);
    }
    elsif (defined($_)) {
      translation_scheme($_);
    }
  }
}

sub type {
 my $type = ref($_[0]);

 if ($type) {
   if (defined($_[1])) {
     $type = $_[1];
     Parse::Eyapp::Driver::BeANode($type);
     bless $_[0], $type;
   }
   return $type 
 }
 return 'Parse::Eyapp::Node::STRING';
}

{ # Tree "fuzzy" equality

####################################################################
# Usage      : $t1->equal($t2, n => sub { return $_[0] == $_[1] })
# Purpose    : Checks the equality between two AST
# Returns    : 1 if equal, 0 if not 'equal'
# Parameters : Two Parse::Eyapp:Node nodes and a hash of comparison handlers.
#              The keys of the hash are the attributes of the nodes. The value is
#              a comparator function. The comparator for key $k receives the attribute
#              for the nodes being visited and rmust return true if they are considered similar
# Throws     : exceptions if the parameters aren't Parse::Eyapp::Nodes

  my %handler;

  # True if the two trees look similar
  sub equal {
    croak "Parse::Eyapp::Node::equal error. Expected two syntax trees \n" unless (@_ > 1);

    %handler = splice(@_, 2);
    my $key = '';
    defined($key=firstval {!UNIVERSAL::isa($handler{$_},'CODE') } keys %handler) 
    and 
      croak "Parse::Eyapp::Node::equal error. Expected a CODE ref for attribute $key\n";
    goto &_equal;
  }

  sub _equal {
    my $tree1 = CORE::shift;
    my $tree2 = CORE::shift;

    # Same type
    return 0 unless ref($tree1) eq ref($tree2);

    # Check attributes via handlers
    for (keys %handler) {
      # Check for existence
      return 0 if (exists($tree1->{$_}) && !exists($tree2->{$_}));
      return 0 if (exists($tree2->{$_}) && !exists($tree1->{$_}));

      # Check for definition
      return 0 if (defined($tree1->{$_}) && !defined($tree2->{$_}));
      return 0 if (defined($tree2->{$_}) && !defined($tree1->{$_}));

      # Check for equality
      return 0 unless $handler{$_}->($tree1->{$_}, $tree2->{$_});
    }

    # Same number of children
    my @children1 = @{$tree1->{children}};
    my @children2 = @{$tree2->{children}};
    return 0 unless @children1 == @children2;

    # Children must be similar
    for (@children1) {
      my $ch2 = CORE::shift @children2;
      return 0 unless _equal($_, $ch2);
    }
    return 1;
  }
}

1;

package Parse::Eyapp::Node::Match;
our @ISA = qw(Parse::Eyapp::Node);

# A Parse::Eyapp::Node::Match object is a reference
# to a tree of Parse::Eyapp::Nodes that has been used
# in a tree matching regexp. You can think of them
# as the equivalent of $1 $2, ... in treeregexeps

# The depth of the Parse::Eyapp::Node being referenced

sub new {
  my $class = shift;

  my $matchnode = { @_ };
  $matchnode->{children} = [];
  bless $matchnode, $class;
}

sub depth {
  my $self = shift;

  return $self->{depth};
}

# The coordinates of the Parse::Eyapp::Node being referenced
sub coord {
  my $self = shift;

  return $self->{dewey};
}


# The Parse::Eyapp::Node being referenced
sub node {
  my $self = shift;

  return $self->{node};
}

# The Parse::Eyapp::Node:Match that references
# the nearest ancestor of $self->{node} that matched
sub father {
  my $self = shift;

  return $self->{father};
}
  
# The patterns that matched with $self->{node}
# Indexes
sub patterns {
  my $self = shift;

  @{$self->{patterns}} = @_ if @_;
  return @{$self->{patterns}};
}
  
# The original list of patterns that produced this match
sub family {
  my $self = shift;

  @{$self->{family}} = @_ if @_;
  return @{$self->{family}};
}
  
# The names of the patterns that matched
sub names {
  my $self = shift;

  my @indexes = $self->patterns;
  my @family = $self->family;

  return map { $_->{NAME} or "Unknown" } @family[@indexes];
}
  
sub info {
  my $self = shift;

  my $node = $self->node;
  my @names = $self->names;
  my $nodeinfo;
  if (UNIVERSAL::can($node, 'info')) {
    $nodeinfo = ":".$node->info;
  }
  else {
    $nodeinfo = "";
  }
  return "[".ref($self->node).":".$self->depth.":@names$nodeinfo]"
}

1;



MODULE_Parse_Eyapp_Node
    }; # Unless Parse::Eyapp::Node was loaded
  } ########### End of BEGIN { load perl-local/lib/perl5/site_perl//5.16.2/Parse/Eyapp/Node.pm }

  # Loading Parse::Eyapp::YATW
  BEGIN {
    unless (Parse::Eyapp::YATW->can('m')) {
      eval << 'MODULE_Parse_Eyapp_YATW'
# (c) Parse::Eyapp Copyright 2006-2008 Casiano Rodriguez-Leon, all rights reserved.
package Parse::Eyapp::YATW;
use strict;
use warnings;
use Carp;
use Data::Dumper;
use List::Util qw(first);

sub firstval(&@) {
  my $handler = shift;
  
  return (grep { $handler->($_) } @_)[0]
}

sub lastval(&@) {
  my $handler = shift;
  
  return (grep { $handler->($_) } @_)[-1]
}

sub valid_keys {
  my %valid_args = @_;

  my @valid_args = keys(%valid_args); 
  local $" = ", "; 
  return "@valid_args" 
}

sub invalid_keys {
  my $valid_args = shift;
  my $args = shift;

  return (first { !exists($valid_args->{$_}) } keys(%$args));
}


our $VERSION = $Parse::Eyapp::Driver::VERSION;

our $FILENAME=__FILE__;

# TODO: Check args. Typical args:
# 'CHANGES' => 0,
# 'PATTERN' => sub { "DUMMY" },
# 'NAME' => 'fold',
# 'PATTERN_ARGS' => [],
# 'PENDING_TASKS' => {},
# 'NODE' => []

my %_new_yatw = (
  PATTERN => 'CODE',
  NAME => 'STRING',
);

my $validkeys = valid_keys(%_new_yatw); 

sub new {
  my $class = shift;
  my %args = @_;

  croak "Error. Expected a code reference when building a tree walker. " unless (ref($args{PATTERN}) eq 'CODE');
  if (defined($a = invalid_keys(\%_new_yatw, \%args))) {
    croak("Parse::Eyapp::YATW::new Error!: unknown argument $a. Valid arguments are: $validkeys")
  }


  # obsolete, I have to delete this
  #$args{PATTERN_ARGS} = [] unless (ref($args{PATTERN_ARGS}) eq 'ARRAY'); 

  # Internal fields

  # Tell us if the node has changed after the visit
  $args{CHANGES} = 0;
  
  # PENDING_TASKS is a queue storing the tasks waiting for a "safe time/node" to do them 
  # Usually that time occurs when visiting the father of the node who generated the job 
  # (when asap criteria is applied).
  # Keys are node references. Values are array references. Each entry defines:
  #  [ the task kind, the node where to do the job, and info related to the particular job ]
  # Example: @{$self->{PENDING_TASKS}{$father}}, ['insert_before', $node, ${$self->{NODE}}[0] ];
  $args{PENDING_TASKS} = {};

  # NODE is a stack storing the ancestor of the node being visited
  # Example: my $ancestor = ${$self->{NODE}}[$k]; when k=1 is the father, k=2 the grandfather, etc.
  # Example: CORE::unshift @{$self->{NODE}}, $_[0]; Finished the visit so take it out
  $args{NODE} = [];

  bless \%args, $class;
}

sub buildpatterns {
  my $class = shift;
  
  my @family;
  while (my ($n, $p) = splice(@_, 0,2)) {
    push @family, Parse::Eyapp::YATW->new(NAME => $n, PATTERN => $p);
  }
  return wantarray? @family : $family[0];
}

####################################################################
# Usage      : @r = $b{$_}->m($t)
#              See Simple4.eyp and m_yatw.pl in the examples directory
# Returns    : Returns an array of nodes matching the treeregexp
#              The set of nodes is a Parse::Eyapp::Node::Match tree 
#              showing the relation between the matches
# Parameters : The tree (and the object of course)
# depth is no longer used: eliminate
sub m {
  my $p = shift(); # pattern YATW object
  my $t = shift;   # tree
  my $pattern = $p->{PATTERN}; # CODE ref

  # References to the found nodes are stored in @stack
  my @stack = ( Parse::Eyapp::Node::Match->new(node=>$t, depth=>0, dewey => "") ); 
  my @results;
  do {
    my $n = CORE::shift(@stack);
    my %n = %$n;

    my $dewey = $n->{dewey};
    my $d = $n->{depth};
    if ($pattern->($n{node})) {
      $n->{family} = [ $p ];
      $n->{patterns} = [ 0 ];

      # Is at this time that I have to compute the father
      my $f = lastval { $dewey =~ m{^$_->{dewey}}} @results;
      $n->{father} = $f;
      # ... and children
      push @{$f->{children}}, $n if defined($f);
      push @results, $n;
    }
    my $k = 0;
    CORE::unshift @stack, 
       map { 
              local $a;
              $a = Parse::Eyapp::Node::Match->new(node=>$_, depth=>$d+1, dewey=>"$dewey.$k" );
              $k++;
              $a;
           } $n{node}->children();
  } while (@stack);

  return wantarray? @results : $results[0];
}

######################### getter-setter for YATW objects ###########################

sub pattern {
  my $self = shift;
  $self->{PATTERN} = shift if (@_);
  return $self->{PATTERN};
}

sub name {
  my $self = shift;
  $self->{NAME} = shift if (@_);
  return $self->{NAME};
}

#sub pattern_args {
#  my $self = shift;
#
#  $self->{PATTERN_ARGS} = @_ if @_;
#  return @{$self->{PATTERN_ARGS}};
#}

########################## PENDING TASKS management ################################

# Purpose    : Deletes the node that matched from the list of children of its father. 
sub delete {
  my $self = shift;

  bless $self->{NODE}[0], 'Parse::Eyapp::Node::DELETE';
}
  
sub make_delete_effective {
  my $self = shift;
  my $node = shift;

  my $i = -1+$node->children;
  while ($i >= 0) {
    if (UNIVERSAL::isa($node->child($i), 'Parse::Eyapp::Node::DELETE')) {
      $self->{CHANGES}++ if defined(splice(@{$node->{children}}, $i, 1));
    }
    $i--;
  }
}

####################################################################
# Usage      :    my $b = Parse::Eyapp::Node->new( 'NUM(TERMINAL)', sub { $_[1]->{attr} = 4 });
#                 $yatw_pattern->unshift($b); 
# Parameters : YATW object, node to insert, 
#              ancestor offset: 0 = root of the tree that matched, 1 = father, 2 = granfather, etc.

sub unshift {
  my ($self, $node, $k) = @_;
  $k = 1 unless defined($k); # father by default

  my $ancestor = ${$self->{NODE}}[$k];
  croak "unshift: does not exist ancestor $k of node ".Dumper(${$self->{NODE}}[0]) unless defined($ancestor);

  # Stringification of $ancestor. Hope it works
                                            # operation, node to insert, 
  push @{$self->{PENDING_TASKS}{$ancestor}}, ['unshift', $node ];
}

sub insert_before {
  my ($self, $node) = @_;

  my $father = ${$self->{NODE}}[1];
  croak "insert_before: does not exist father of node ".Dumper(${$self->{NODE}}[0]) unless defined($father);

                                           # operation, node to insert, before this node 
  push @{$self->{PENDING_TASKS}{$father}}, ['insert_before', $node, ${$self->{NODE}}[0] ];
}

sub _delayed_insert_before {
  my ($father, $node, $before) = @_;

  my $i = 0;
  for ($father->children()) {
    last if ($_ == $before);
    $i++;
  }
  splice @{$father->{children}}, $i, 0, $node;
}

sub do_pending_tasks {
  my $self = shift;
  my $node = shift;

  my $mytasks = $self->{PENDING_TASKS}{$node};
  while ($mytasks and (my $job = shift @{$mytasks})) {
    my @args = @$job;
    my $task = shift @args;

    # change this for a jump table
    if ($task eq 'unshift') {
      CORE::unshift(@{$node->{children}}, @args);
      $self->{CHANGES}++;
    }
    elsif ($task eq 'insert_before') {
      _delayed_insert_before($node, @args);
      $self->{CHANGES}++;
    }
  }
}

####################################################################
# Parameters : pattern, node, father of the node, index of the child in the children array
# YATW object. Probably too many 
sub s {
  my $self = shift;
  my $node = $_[0] or croak("Error. Method __PACKAGE__::s requires a node");
  CORE::unshift @{$self->{NODE}}, $_[0];
  # father is $_[1]
  my $index = $_[2];

  # If is not a reference or can't children then simply check the matching and leave
  if (!ref($node) or !UNIVERSAL::can($node, "children"))  {
                                         
    $self->{CHANGES}++ if $self->pattern->(
      $_[0],  # Node being visited  
      $_[1],  # Father of this node
      $index, # Index of this node in @Father->children
      $self,  # The YATW pattern object   
    );
    return;
  };
  
  # Else, is not a leaf and is a regular Parse::Eyapp::Node
  # Recursively transform subtrees
  my $i = 0;
  for (@{$node->{children}}) {
    $self->s($_, $_[0], $i);
    $i++;
  }
  
  my $number_of_changes = $self->{CHANGES};
  # Now is safe to delete children nodes that are no longer needed
  $self->make_delete_effective($node);

  # Safely do pending jobs for this node
  $self->do_pending_tasks($node);

  #node , father, childindex, and ... 
  #Change YATW object to be the  first argument?
  if ($self->pattern->($_[0], $_[1], $index, $self)) {
    $self->{CHANGES}++;
  }
  shift @{$self->{NODE}};
}

1;


MODULE_Parse_Eyapp_YATW
    }; # Unless Parse::Eyapp::YATW was loaded
  } ########### End of BEGIN { load perl-local/lib/perl5/site_perl//5.16.2/Parse/Eyapp/YATW.pm }



sub unexpendedInput { defined($_) ? substr($_, (defined(pos $_) ? pos $_ : 0)) : '' }

#line 32 "src/sh.yp"

# Initialization

no warnings 'redefine';

# Operators:
our %operators = qw(
		&&  AND_IF
		||  OR_IF
		;;  DSEMI
		<<  DLESS
		>>  DGREAT
		<&  LESSAND
		>&  GREATAND
		<>  LESSGREAT
		<<- DLESSDASH
		>|  CLOBBER
		
		&>  ANDGREAT
		<<< TLESS
	);

# Reserved words are words that have special meaning to the shell;
# The following words shall be recognized as reserved words:
our %reserved = qw(
		if	 If
		then   Then
		else   Else
		elif   Elif
		fi	 Fi
		do	 Do
		done   Done
		case   Case
		esac   Esac
		while  While
		until  Until
		for	For
		{	  Lbrace
		}	  Rbrace
		!	  Bang
		in	 In
		
		function Function
		select   Select
	);


# Default lexical analyzer
our $LEX = sub {
    my $self = shift;
    my $pos;

    for (${$self->input}) {
      

      m{\G(\s+)}gc and $self->tokenline($1 =~ tr{\n}{});

      m{\G(\>\(|\<\(|\<|\||\(|\>|\;|\)|\&)}gc and return ($1, $1);

      /\G(error)/gc and return ($1, $1);
      /\G(DSEMI)/gc and return ($1, $1);
      /\G(OR_IF)/gc and return ($1, $1);
      /\G(AND_IF)/gc and return ($1, $1);
      /\G(LESSAND)/gc and return ($1, $1);
      /\G(GREATAND)/gc and return ($1, $1);
      /\G(DLESSDASH)/gc and return ($1, $1);
      /\G(LESSGREAT)/gc and return ($1, $1);
      /\G(DLESS)/gc and return ($1, $1);
      /\G(DGREAT)/gc and return ($1, $1);
      /\G(CLOBBER)/gc and return ($1, $1);
      /\G(TLESS)/gc and return ($1, $1);
      /\G(ANDGREAT)/gc and return ($1, $1);
      /\G(Elif)/gc and return ($1, $1);
      /\G(Fi)/gc and return ($1, $1);
      /\G(Then)/gc and return ($1, $1);
      /\G(Done)/gc and return ($1, $1);
      /\G(Do)/gc and return ($1, $1);
      /\G(If)/gc and return ($1, $1);
      /\G(Else)/gc and return ($1, $1);
      /\G(Until)/gc and return ($1, $1);
      /\G(Case)/gc and return ($1, $1);
      /\G(Esac)/gc and return ($1, $1);
      /\G(While)/gc and return ($1, $1);
      /\G(For)/gc and return ($1, $1);
      /\G(Function)/gc and return ($1, $1);
      /\G(Select)/gc and return ($1, $1);
      /\G(Lbrace)/gc and return ($1, $1);
      /\G(Rbrace)/gc and return ($1, $1);
      /\G(Bang)/gc and return ($1, $1);
      /\G(In)/gc and return ($1, $1);
      /\G(WORD)/gc and return ($1, $1);
      /\G(ASSIGNMENT_WORD)/gc and return ($1, $1);
      /\G(NEWLINE)/gc and return ($1, $1);
      /\G(IO_NUMBER)/gc and return ($1, $1);
      /\G(DPAR)/gc and return ($1, $1);


      return ('', undef) if ($_ eq '') || (defined(pos($_)) && (pos($_) >= length($_)));
      /\G\s*(\S+)/;
      my $near = substr($1,0,10); 

      return($near, $near);

     # die( "Error inside the lexical analyzer near '". $near
     #     ."'. Line: ".$self->line()
     #     .". File: '".$self->YYFilename()."'. No match found.\n");
    }
  }
;


#line 3536 ShParser.pm

my $warnmessage =<< "EOFWARN";
Warning!: Did you changed the \@ShParser::ISA variable inside the header section of the eyapp program?
EOFWARN

sub new {
  my($class)=shift;
  ref($class) and $class=ref($class);

  warn $warnmessage unless __PACKAGE__->isa('Parse::Eyapp::Driver'); 
  my($self)=$class->SUPER::new( 
    yyversion => '1.181',
    yyGRAMMAR  =>
[#[productionNameAndLabel => lhs, [ rhs], bypass]]
  [ '_SUPERSTART' => '$start', [ 'start', '$end' ], 0 ],
  [ 'start_1' => 'start', [ 'compound_list' ], 0 ],
  [ 'start_2' => 'start', [ 'linebreak' ], 0 ],
  [ 'and_or_3' => 'and_or', [ 'pipeline' ], 0 ],
  [ 'and_or_4' => 'and_or', [ 'and_or', 'AND_IF', 'linebreak', 'pipeline' ], 0 ],
  [ 'and_or_5' => 'and_or', [ 'and_or', 'OR_IF', 'linebreak', 'pipeline' ], 0 ],
  [ 'pipeline_6' => 'pipeline', [ 'pipe_sequence' ], 0 ],
  [ 'pipeline_7' => 'pipeline', [ 'Bang', 'pipe_sequence' ], 0 ],
  [ 'pipe_sequence_8' => 'pipe_sequence', [ 'command' ], 0 ],
  [ 'pipe_sequence_9' => 'pipe_sequence', [ 'pipe_sequence', '|', 'linebreak', 'command' ], 0 ],
  [ 'command_10' => 'command', [ 'simple_command' ], 0 ],
  [ 'command_11' => 'command', [ 'compound_command' ], 0 ],
  [ 'command_12' => 'command', [ 'compound_command', 'redirect_list' ], 0 ],
  [ 'command_13' => 'command', [ 'function_definition' ], 0 ],
  [ 'compound_command_14' => 'compound_command', [ 'brace_group' ], 0 ],
  [ 'compound_command_15' => 'compound_command', [ 'DPAR' ], 0 ],
  [ 'compound_command_16' => 'compound_command', [ 'subshell' ], 0 ],
  [ 'compound_command_17' => 'compound_command', [ 'for_clause' ], 0 ],
  [ 'compound_command_18' => 'compound_command', [ 'case_clause' ], 0 ],
  [ 'compound_command_19' => 'compound_command', [ 'if_clause' ], 0 ],
  [ 'compound_command_20' => 'compound_command', [ 'while_clause' ], 0 ],
  [ 'compound_command_21' => 'compound_command', [ 'until_clause' ], 0 ],
  [ 'compound_command_22' => 'compound_command', [ 'select_clause' ], 0 ],
  [ 'subshell_23' => 'subshell', [ '(', 'compound_list', ')' ], 0 ],
  [ 'compound_list_24' => 'compound_list', [ 'term' ], 0 ],
  [ 'compound_list_25' => 'compound_list', [ 'newline_list', 'term' ], 0 ],
  [ 'compound_list_26' => 'compound_list', [ 'term', 'separator' ], 0 ],
  [ 'compound_list_27' => 'compound_list', [ 'newline_list', 'term', 'separator' ], 0 ],
  [ 'compound_list_s_28' => 'compound_list_s', [ 'term', 'separator' ], 0 ],
  [ 'compound_list_s_29' => 'compound_list_s', [ 'newline_list', 'term', 'separator' ], 0 ],
  [ 'term_30' => 'term', [ 'term', 'separator', 'and_or' ], 0 ],
  [ 'term_31' => 'term', [ 'and_or' ], 0 ],
  [ 'term_32' => 'term', [ 'error', 'separator', 'and_or' ], 0 ],
  [ 'select_clause_33' => 'select_clause', [ 'Select', 'name', 'linebreak', 'do_group' ], 0 ],
  [ 'select_clause_34' => 'select_clause', [ 'Select', 'name', 'linebreak', 'in', 'wordlist', 'sequential_sep', 'do_group' ], 0 ],
  [ 'for_clause_35' => 'for_clause', [ 'For', 'name', 'linebreak', 'do_group' ], 0 ],
  [ 'for_clause_36' => 'for_clause', [ 'For', 'name', 'sequential_sep', 'do_group' ], 0 ],
  [ 'for_clause_37' => 'for_clause', [ 'For', 'name', 'linebreak', 'in', 'sequential_sep', 'do_group' ], 0 ],
  [ 'for_clause_38' => 'for_clause', [ 'For', 'name', 'linebreak', 'in', 'wordlist', 'sequential_sep', 'do_group' ], 0 ],
  [ 'for_clause_39' => 'for_clause', [ 'For', 'DPAR', 'sequential_sep', 'do_group' ], 0 ],
  [ 'for_clause_40' => 'for_clause', [ 'For', 'DPAR', 'do_group' ], 0 ],
  [ 'name_41' => 'name', [ 'NAME' ], 0 ],
  [ 'in_42' => 'in', [ 'In' ], 0 ],
  [ 'wordlist_43' => 'wordlist', [ 'wordlist', 'WORD' ], 0 ],
  [ 'wordlist_44' => 'wordlist', [ 'WORD' ], 0 ],
  [ 'case_clause_45' => 'case_clause', [ 'Case', 'WORD', 'linebreak', 'in', 'linebreak', 'case_list', 'Esac' ], 0 ],
  [ 'case_clause_46' => 'case_clause', [ 'Case', 'WORD', 'linebreak', 'in', 'linebreak', 'case_list_ns', 'Esac' ], 0 ],
  [ 'case_clause_47' => 'case_clause', [ 'Case', 'WORD', 'linebreak', 'in', 'linebreak', 'Esac' ], 0 ],
  [ 'case_list_ns_48' => 'case_list_ns', [ 'case_list', 'case_item_ns' ], 0 ],
  [ 'case_list_ns_49' => 'case_list_ns', [ 'case_item_ns' ], 0 ],
  [ 'case_list_50' => 'case_list', [ 'case_list', 'case_item' ], 0 ],
  [ 'case_list_51' => 'case_list', [ 'case_item' ], 0 ],
  [ 'case_item_ns_52' => 'case_item_ns', [ 'pattern_list', ')', 'linebreak' ], 0 ],
  [ 'case_item_ns_53' => 'case_item_ns', [ 'pattern_list', ')', 'compound_list_s' ], 0 ],
  [ 'case_item_ns_54' => 'case_item_ns', [ '(', 'pattern_list', ')', 'linebreak' ], 0 ],
  [ 'case_item_ns_55' => 'case_item_ns', [ '(', 'pattern_list', ')', 'compound_list_s' ], 0 ],
  [ 'case_item_56' => 'case_item', [ 'pattern_list', ')', 'linebreak', 'DSEMI', 'linebreak' ], 0 ],
  [ 'case_item_57' => 'case_item', [ 'pattern_list', ')', 'compound_list', 'DSEMI', 'linebreak' ], 0 ],
  [ 'case_item_58' => 'case_item', [ '(', 'pattern_list', ')', 'linebreak', 'DSEMI', 'linebreak' ], 0 ],
  [ 'case_item_59' => 'case_item', [ '(', 'pattern_list', ')', 'compound_list', 'DSEMI', 'linebreak' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-1', [ 'pattern' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-1', [  ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-2', [ 'pattern' ], 0 ],
  [ '_OPTIONAL' => 'OPTIONAL-2', [  ], 0 ],
  [ 'pattern_64' => 'pattern', [ 'WORD' ], 0 ],
  [ 'pattern_65' => 'pattern', [ 'OPTIONAL-1', '(', 'pattern_list', ')', 'OPTIONAL-2' ], 0 ],
  [ 'pattern_list_66' => 'pattern_list', [ 'pattern' ], 0 ],
  [ 'pattern_list_67' => 'pattern_list', [ 'pattern_list', '|', 'pattern' ], 0 ],
  [ 'if_clause_68' => 'if_clause', [ 'If', 'compound_list_s', 'Then', 'compound_list_s', 'else_part', 'Fi' ], 0 ],
  [ 'if_clause_69' => 'if_clause', [ 'If', 'compound_list_s', 'Then', 'compound_list_s', 'Fi' ], 0 ],
  [ 'else_part_70' => 'else_part', [ 'Elif', 'compound_list_s', 'Then', 'compound_list_s' ], 0 ],
  [ 'else_part_71' => 'else_part', [ 'Elif', 'compound_list_s', 'Then', 'compound_list_s', 'else_part' ], 0 ],
  [ 'else_part_72' => 'else_part', [ 'Else', 'compound_list_s' ], 0 ],
  [ 'while_clause_73' => 'while_clause', [ 'While', 'compound_list_s', 'do_group' ], 0 ],
  [ 'until_clause_74' => 'until_clause', [ 'Until', 'compound_list_s', 'do_group' ], 0 ],
  [ 'function_definition_75' => 'function_definition', [ 'Function', 'fname', '(', ')', 'linebreak', 'function_body' ], 0 ],
  [ 'function_definition_76' => 'function_definition', [ 'Function', 'fname', 'linebreak', 'function_body' ], 0 ],
  [ 'function_definition_77' => 'function_definition', [ 'fname', '(', ')', 'linebreak', 'function_body' ], 0 ],
  [ 'function_body_78' => 'function_body', [ 'compound_command' ], 0 ],
  [ 'function_body_79' => 'function_body', [ 'compound_command', 'redirect_list' ], 0 ],
  [ 'fname_80' => 'fname', [ 'NAME' ], 0 ],
  [ 'brace_group_81' => 'brace_group', [ 'Lbrace', 'compound_list', 'Rbrace' ], 0 ],
  [ 'do_group_82' => 'do_group', [ 'Do', 'compound_list_s', 'Done' ], 0 ],
  [ 'simple_command_83' => 'simple_command', [ 'cmd_prefix', 'cmd_word', 'cmd_suffix' ], 0 ],
  [ 'simple_command_84' => 'simple_command', [ 'cmd_prefix', 'cmd_word' ], 0 ],
  [ 'simple_command_85' => 'simple_command', [ 'cmd_prefix' ], 0 ],
  [ 'simple_command_86' => 'simple_command', [ 'cmd_word', 'cmd_suffix' ], 0 ],
  [ 'simple_command_87' => 'simple_command', [ 'cmd_word' ], 0 ],
  [ 'cmd_word_88' => 'cmd_word', [ 'WORD' ], 0 ],
  [ 'cmd_prefix_89' => 'cmd_prefix', [ 'io_redirect' ], 0 ],
  [ 'cmd_prefix_90' => 'cmd_prefix', [ 'cmd_prefix', 'io_redirect' ], 0 ],
  [ 'cmd_prefix_91' => 'cmd_prefix', [ 'ASSIGNMENT_WORD' ], 0 ],
  [ 'cmd_prefix_92' => 'cmd_prefix', [ 'cmd_prefix', 'ASSIGNMENT_WORD' ], 0 ],
  [ 'cmd_suffix_93' => 'cmd_suffix', [ 'io_redirect' ], 0 ],
  [ 'cmd_suffix_94' => 'cmd_suffix', [ 'cmd_suffix', 'io_redirect' ], 0 ],
  [ 'cmd_suffix_95' => 'cmd_suffix', [ 'filename' ], 0 ],
  [ 'cmd_suffix_96' => 'cmd_suffix', [ 'cmd_suffix', 'filename' ], 0 ],
  [ 'cmd_suffix_97' => 'cmd_suffix', [ 'WORD' ], 0 ],
  [ 'cmd_suffix_98' => 'cmd_suffix', [ 'cmd_suffix', 'WORD' ], 0 ],
  [ 'redirect_list_99' => 'redirect_list', [ 'io_redirect' ], 0 ],
  [ 'redirect_list_100' => 'redirect_list', [ 'redirect_list', 'io_redirect' ], 0 ],
  [ 'io_redirect_101' => 'io_redirect', [ 'io_file' ], 0 ],
  [ 'io_redirect_102' => 'io_redirect', [ 'IO_NUMBER', 'io_file' ], 0 ],
  [ 'io_redirect_103' => 'io_redirect', [ 'io_here' ], 0 ],
  [ 'io_redirect_104' => 'io_redirect', [ 'IO_NUMBER', 'io_here' ], 0 ],
  [ 'io_redirect_105' => 'io_redirect', [ 'ANDGREAT', 'filename' ], 0 ],
  [ 'io_redirect_106' => 'io_redirect', [ 'TLESS', 'WORD' ], 0 ],
  [ 'io_file_107' => 'io_file', [ '<', 'filename' ], 0 ],
  [ 'io_file_108' => 'io_file', [ 'LESSAND', 'filename' ], 0 ],
  [ 'io_file_109' => 'io_file', [ '>', 'filename' ], 0 ],
  [ 'io_file_110' => 'io_file', [ 'GREATAND', 'filename' ], 0 ],
  [ 'io_file_111' => 'io_file', [ 'DGREAT', 'filename' ], 0 ],
  [ 'io_file_112' => 'io_file', [ 'LESSGREAT', 'filename' ], 0 ],
  [ 'io_file_113' => 'io_file', [ 'CLOBBER', 'filename' ], 0 ],
  [ 'filename_114' => 'filename', [ 'WORD' ], 0 ],
  [ 'filename_115' => 'filename', [ '<(', 'compound_list', ')' ], 0 ],
  [ 'filename_116' => 'filename', [ '>(', 'compound_list', ')' ], 0 ],
  [ 'io_here_117' => 'io_here', [ 'DLESS', 'here_end' ], 0 ],
  [ 'io_here_118' => 'io_here', [ 'DLESSDASH', 'here_end' ], 0 ],
  [ 'here_end_119' => 'here_end', [ 'WORD' ], 0 ],
  [ 'newline_list_120' => 'newline_list', [ 'NEWLINE' ], 0 ],
  [ 'newline_list_121' => 'newline_list', [ 'newline_list', 'NEWLINE' ], 0 ],
  [ 'linebreak_122' => 'linebreak', [ 'newline_list' ], 0 ],
  [ 'linebreak_123' => 'linebreak', [  ], 0 ],
  [ 'separator_op_124' => 'separator_op', [ '&' ], 0 ],
  [ 'separator_op_125' => 'separator_op', [ ';' ], 0 ],
  [ 'separator_126' => 'separator', [ 'separator_op', 'linebreak' ], 0 ],
  [ 'separator_127' => 'separator', [ 'newline_list' ], 0 ],
  [ 'sequential_sep_128' => 'sequential_sep', [ ';', 'linebreak' ], 0 ],
  [ 'sequential_sep_129' => 'sequential_sep', [ 'newline_list' ], 0 ],
  [ 'NAME_130' => 'NAME', [ 'WORD' ], 0 ],
],
    yyLABELS  =>
{
  '_SUPERSTART' => 0,
  'start_1' => 1,
  'start_2' => 2,
  'and_or_3' => 3,
  'and_or_4' => 4,
  'and_or_5' => 5,
  'pipeline_6' => 6,
  'pipeline_7' => 7,
  'pipe_sequence_8' => 8,
  'pipe_sequence_9' => 9,
  'command_10' => 10,
  'command_11' => 11,
  'command_12' => 12,
  'command_13' => 13,
  'compound_command_14' => 14,
  'compound_command_15' => 15,
  'compound_command_16' => 16,
  'compound_command_17' => 17,
  'compound_command_18' => 18,
  'compound_command_19' => 19,
  'compound_command_20' => 20,
  'compound_command_21' => 21,
  'compound_command_22' => 22,
  'subshell_23' => 23,
  'compound_list_24' => 24,
  'compound_list_25' => 25,
  'compound_list_26' => 26,
  'compound_list_27' => 27,
  'compound_list_s_28' => 28,
  'compound_list_s_29' => 29,
  'term_30' => 30,
  'term_31' => 31,
  'term_32' => 32,
  'select_clause_33' => 33,
  'select_clause_34' => 34,
  'for_clause_35' => 35,
  'for_clause_36' => 36,
  'for_clause_37' => 37,
  'for_clause_38' => 38,
  'for_clause_39' => 39,
  'for_clause_40' => 40,
  'name_41' => 41,
  'in_42' => 42,
  'wordlist_43' => 43,
  'wordlist_44' => 44,
  'case_clause_45' => 45,
  'case_clause_46' => 46,
  'case_clause_47' => 47,
  'case_list_ns_48' => 48,
  'case_list_ns_49' => 49,
  'case_list_50' => 50,
  'case_list_51' => 51,
  'case_item_ns_52' => 52,
  'case_item_ns_53' => 53,
  'case_item_ns_54' => 54,
  'case_item_ns_55' => 55,
  'case_item_56' => 56,
  'case_item_57' => 57,
  'case_item_58' => 58,
  'case_item_59' => 59,
  '_OPTIONAL' => 60,
  '_OPTIONAL' => 61,
  '_OPTIONAL' => 62,
  '_OPTIONAL' => 63,
  'pattern_64' => 64,
  'pattern_65' => 65,
  'pattern_list_66' => 66,
  'pattern_list_67' => 67,
  'if_clause_68' => 68,
  'if_clause_69' => 69,
  'else_part_70' => 70,
  'else_part_71' => 71,
  'else_part_72' => 72,
  'while_clause_73' => 73,
  'until_clause_74' => 74,
  'function_definition_75' => 75,
  'function_definition_76' => 76,
  'function_definition_77' => 77,
  'function_body_78' => 78,
  'function_body_79' => 79,
  'fname_80' => 80,
  'brace_group_81' => 81,
  'do_group_82' => 82,
  'simple_command_83' => 83,
  'simple_command_84' => 84,
  'simple_command_85' => 85,
  'simple_command_86' => 86,
  'simple_command_87' => 87,
  'cmd_word_88' => 88,
  'cmd_prefix_89' => 89,
  'cmd_prefix_90' => 90,
  'cmd_prefix_91' => 91,
  'cmd_prefix_92' => 92,
  'cmd_suffix_93' => 93,
  'cmd_suffix_94' => 94,
  'cmd_suffix_95' => 95,
  'cmd_suffix_96' => 96,
  'cmd_suffix_97' => 97,
  'cmd_suffix_98' => 98,
  'redirect_list_99' => 99,
  'redirect_list_100' => 100,
  'io_redirect_101' => 101,
  'io_redirect_102' => 102,
  'io_redirect_103' => 103,
  'io_redirect_104' => 104,
  'io_redirect_105' => 105,
  'io_redirect_106' => 106,
  'io_file_107' => 107,
  'io_file_108' => 108,
  'io_file_109' => 109,
  'io_file_110' => 110,
  'io_file_111' => 111,
  'io_file_112' => 112,
  'io_file_113' => 113,
  'filename_114' => 114,
  'filename_115' => 115,
  'filename_116' => 116,
  'io_here_117' => 117,
  'io_here_118' => 118,
  'here_end_119' => 119,
  'newline_list_120' => 120,
  'newline_list_121' => 121,
  'linebreak_122' => 122,
  'linebreak_123' => 123,
  'separator_op_124' => 124,
  'separator_op_125' => 125,
  'separator_126' => 126,
  'separator_127' => 127,
  'sequential_sep_128' => 128,
  'sequential_sep_129' => 129,
  'NAME_130' => 130,
},
    yyTERMS  =>
{ '' => { ISSEMANTIC => 0 },
	'&' => { ISSEMANTIC => 0 },
	'(' => { ISSEMANTIC => 0 },
	')' => { ISSEMANTIC => 0 },
	';' => { ISSEMANTIC => 0 },
	'<' => { ISSEMANTIC => 0 },
	'<(' => { ISSEMANTIC => 0 },
	'>' => { ISSEMANTIC => 0 },
	'>(' => { ISSEMANTIC => 0 },
	'|' => { ISSEMANTIC => 0 },
	ANDGREAT => { ISSEMANTIC => 1 },
	AND_IF => { ISSEMANTIC => 1 },
	ASSIGNMENT_WORD => { ISSEMANTIC => 1 },
	Bang => { ISSEMANTIC => 1 },
	CLOBBER => { ISSEMANTIC => 1 },
	Case => { ISSEMANTIC => 1 },
	DGREAT => { ISSEMANTIC => 1 },
	DLESS => { ISSEMANTIC => 1 },
	DLESSDASH => { ISSEMANTIC => 1 },
	DPAR => { ISSEMANTIC => 1 },
	DSEMI => { ISSEMANTIC => 1 },
	Do => { ISSEMANTIC => 1 },
	Done => { ISSEMANTIC => 1 },
	Elif => { ISSEMANTIC => 1 },
	Else => { ISSEMANTIC => 1 },
	Esac => { ISSEMANTIC => 1 },
	Fi => { ISSEMANTIC => 1 },
	For => { ISSEMANTIC => 1 },
	Function => { ISSEMANTIC => 1 },
	GREATAND => { ISSEMANTIC => 1 },
	IO_NUMBER => { ISSEMANTIC => 1 },
	If => { ISSEMANTIC => 1 },
	In => { ISSEMANTIC => 1 },
	LESSAND => { ISSEMANTIC => 1 },
	LESSGREAT => { ISSEMANTIC => 1 },
	Lbrace => { ISSEMANTIC => 1 },
	NEWLINE => { ISSEMANTIC => 1 },
	OR_IF => { ISSEMANTIC => 1 },
	Rbrace => { ISSEMANTIC => 1 },
	Select => { ISSEMANTIC => 1 },
	TLESS => { ISSEMANTIC => 1 },
	Then => { ISSEMANTIC => 1 },
	Until => { ISSEMANTIC => 1 },
	WORD => { ISSEMANTIC => 1 },
	While => { ISSEMANTIC => 1 },
	error => { ISSEMANTIC => 1 },
	error => { ISSEMANTIC => 0 },
},
    yyFILENAME  => 'src/sh.yp',
    yystates =>
[
	{#State 0
		ACTIONS => {
			'' => -123,
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'linebreak' => 3,
			'case_clause' => 2,
			'subshell' => 34,
			'compound_command' => 33,
			'io_file' => 32,
			'newline_list' => 4,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 35,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'compound_list' => 15,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'while_clause' => 53,
			'and_or' => 52,
			'start' => 30
		}
	},
	{#State 1
		ACTIONS => {
			"(" => -130
		},
		DEFAULT => -88
	},
	{#State 2
		DEFAULT => -18
	},
	{#State 3
		DEFAULT => -2
	},
	{#State 4
		ACTIONS => {
			'' => -122,
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 56,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 55,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 5
		ACTIONS => {
			'WORD' => 57,
			">(" => 58,
			"<(" => 60
		},
		GOTOS => {
			'filename' => 59
		}
	},
	{#State 6
		DEFAULT => -91
	},
	{#State 7
		DEFAULT => -89
	},
	{#State 8
		ACTIONS => {
			'WORD' => 61,
			'ANDGREAT' => 31,
			"<" => 5,
			">(" => 58,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28,
			"<(" => 60
		},
		DEFAULT => -87,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'filename' => 63,
			'io_redirect' => 62,
			'cmd_suffix' => 64
		}
	},
	{#State 9
		ACTIONS => {
			"(" => 65
		}
	},
	{#State 10
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 66,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 67,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'compound_list_s' => 68,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 11
		ACTIONS => {
			'WORD' => 69
		},
		GOTOS => {
			'NAME' => 48,
			'fname' => 70
		}
	},
	{#State 12
		DEFAULT => -14
	},
	{#State 13
		ACTIONS => {
			'WORD' => 71
		}
	},
	{#State 14
		ACTIONS => {
			'DLESS' => 47,
			'LESSAND' => 19,
			"<" => 5,
			'CLOBBER' => 23,
			'GREATAND' => 25,
			'DLESSDASH' => 24,
			'LESSGREAT' => 36,
			'DGREAT' => 51,
			">" => 28
		},
		GOTOS => {
			'io_here' => 73,
			'io_file' => 72
		}
	},
	{#State 15
		DEFAULT => -1
	},
	{#State 16
		DEFAULT => -15
	},
	{#State 17
		DEFAULT => -13
	},
	{#State 18
		DEFAULT => -3
	},
	{#State 19
		ACTIONS => {
			'WORD' => 57,
			">(" => 58,
			"<(" => 60
		},
		GOTOS => {
			'filename' => 74
		}
	},
	{#State 20
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 75,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 35,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'compound_list' => 76,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 21
		ACTIONS => {
			'WORD' => 77
		}
	},
	{#State 22
		DEFAULT => -17
	},
	{#State 23
		ACTIONS => {
			'WORD' => 57,
			">(" => 58,
			"<(" => 60
		},
		GOTOS => {
			'filename' => 78
		}
	},
	{#State 24
		ACTIONS => {
			'WORD' => 79
		},
		GOTOS => {
			'here_end' => 80
		}
	},
	{#State 25
		ACTIONS => {
			'WORD' => 57,
			">(" => 58,
			"<(" => 60
		},
		GOTOS => {
			'filename' => 81
		}
	},
	{#State 26
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 75,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 35,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'compound_list' => 82,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 27
		DEFAULT => -21
	},
	{#State 28
		ACTIONS => {
			'WORD' => 57,
			">(" => 58,
			"<(" => 60
		},
		GOTOS => {
			'filename' => 83
		}
	},
	{#State 29
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 66,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 67,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'compound_list_s' => 84,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 30
		ACTIONS => {
			'' => 85
		}
	},
	{#State 31
		ACTIONS => {
			'WORD' => 57,
			">(" => 58,
			"<(" => 60
		},
		GOTOS => {
			'filename' => 86
		}
	},
	{#State 32
		DEFAULT => -101
	},
	{#State 33
		ACTIONS => {
			'ANDGREAT' => 31,
			"<" => 5,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28
		},
		DEFAULT => -11,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'io_redirect' => 87,
			'redirect_list' => 88
		}
	},
	{#State 34
		DEFAULT => -16
	},
	{#State 35
		ACTIONS => {
			";" => 91,
			"&" => 92,
			'NEWLINE' => 44
		},
		DEFAULT => -24,
		GOTOS => {
			'newline_list' => 89,
			'separator' => 93,
			'separator_op' => 90
		}
	},
	{#State 36
		ACTIONS => {
			'WORD' => 57,
			">(" => 58,
			"<(" => 60
		},
		GOTOS => {
			'filename' => 94
		}
	},
	{#State 37
		DEFAULT => -103
	},
	{#State 38
		DEFAULT => -10
	},
	{#State 39
		DEFAULT => -19
	},
	{#State 40
		ACTIONS => {
			'WORD' => 95,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 96,
			"<" => 5,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28
		},
		DEFAULT => -85,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'io_redirect' => 97,
			'cmd_word' => 98
		}
	},
	{#State 41
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 66,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 67,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'compound_list_s' => 99,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 42
		ACTIONS => {
			";" => 91,
			"&" => 92,
			'NEWLINE' => 44
		},
		GOTOS => {
			'newline_list' => 89,
			'separator' => 100,
			'separator_op' => 90
		}
	},
	{#State 43
		ACTIONS => {
			'WORD' => 69
		},
		GOTOS => {
			'NAME' => 102,
			'name' => 101
		}
	},
	{#State 44
		DEFAULT => -120
	},
	{#State 45
		DEFAULT => -8
	},
	{#State 46
		ACTIONS => {
			"|" => 103
		},
		DEFAULT => -6
	},
	{#State 47
		ACTIONS => {
			'WORD' => 79
		},
		GOTOS => {
			'here_end' => 104
		}
	},
	{#State 48
		DEFAULT => -80
	},
	{#State 49
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipe_sequence' => 105,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'while_clause' => 53
		}
	},
	{#State 50
		DEFAULT => -22
	},
	{#State 51
		ACTIONS => {
			'WORD' => 57,
			">(" => 58,
			"<(" => 60
		},
		GOTOS => {
			'filename' => 106
		}
	},
	{#State 52
		ACTIONS => {
			'OR_IF' => 107,
			'AND_IF' => 108
		},
		DEFAULT => -31
	},
	{#State 53
		DEFAULT => -20
	},
	{#State 54
		ACTIONS => {
			'WORD' => 69,
			'DPAR' => 109
		},
		GOTOS => {
			'NAME' => 102,
			'name' => 110
		}
	},
	{#State 55
		ACTIONS => {
			";" => 91,
			"&" => 92,
			'NEWLINE' => 44
		},
		DEFAULT => -25,
		GOTOS => {
			'newline_list' => 89,
			'separator' => 111,
			'separator_op' => 90
		}
	},
	{#State 56
		DEFAULT => -121
	},
	{#State 57
		DEFAULT => -114
	},
	{#State 58
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 75,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 35,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'compound_list' => 112,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 59
		DEFAULT => -107
	},
	{#State 60
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 75,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 35,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'compound_list' => 113,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 61
		DEFAULT => -97
	},
	{#State 62
		DEFAULT => -93
	},
	{#State 63
		DEFAULT => -95
	},
	{#State 64
		ACTIONS => {
			'WORD' => 114,
			'ANDGREAT' => 31,
			"<" => 5,
			">(" => 58,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28,
			"<(" => 60
		},
		DEFAULT => -86,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'filename' => 116,
			'io_redirect' => 115
		}
	},
	{#State 65
		ACTIONS => {
			")" => 117
		}
	},
	{#State 66
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 56,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 118,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 67
		ACTIONS => {
			";" => 91,
			"&" => 92,
			'NEWLINE' => 44
		},
		GOTOS => {
			'newline_list' => 89,
			'separator' => 119,
			'separator_op' => 90
		}
	},
	{#State 68
		ACTIONS => {
			'Do' => 121
		},
		GOTOS => {
			'do_group' => 120
		}
	},
	{#State 69
		DEFAULT => -130
	},
	{#State 70
		ACTIONS => {
			"(" => 124,
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 122,
			'newline_list' => 123
		}
	},
	{#State 71
		DEFAULT => -106
	},
	{#State 72
		DEFAULT => -102
	},
	{#State 73
		DEFAULT => -104
	},
	{#State 74
		DEFAULT => -108
	},
	{#State 75
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 56,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 55,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 76
		ACTIONS => {
			'Rbrace' => 125
		}
	},
	{#State 77
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 126,
			'newline_list' => 123
		}
	},
	{#State 78
		DEFAULT => -113
	},
	{#State 79
		DEFAULT => -119
	},
	{#State 80
		DEFAULT => -118
	},
	{#State 81
		DEFAULT => -110
	},
	{#State 82
		ACTIONS => {
			")" => 127
		}
	},
	{#State 83
		DEFAULT => -109
	},
	{#State 84
		ACTIONS => {
			'Do' => 121
		},
		GOTOS => {
			'do_group' => 128
		}
	},
	{#State 85
		DEFAULT => 0
	},
	{#State 86
		DEFAULT => -105
	},
	{#State 87
		DEFAULT => -99
	},
	{#State 88
		ACTIONS => {
			'ANDGREAT' => 31,
			"<" => 5,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28
		},
		DEFAULT => -12,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'io_redirect' => 129
		}
	},
	{#State 89
		ACTIONS => {
			'NEWLINE' => 56
		},
		DEFAULT => -127
	},
	{#State 90
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 130,
			'newline_list' => 123
		}
	},
	{#State 91
		DEFAULT => -125
	},
	{#State 92
		DEFAULT => -124
	},
	{#State 93
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		DEFAULT => -26,
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 131,
			'while_clause' => 53
		}
	},
	{#State 94
		DEFAULT => -112
	},
	{#State 95
		DEFAULT => -88
	},
	{#State 96
		DEFAULT => -92
	},
	{#State 97
		DEFAULT => -90
	},
	{#State 98
		ACTIONS => {
			'WORD' => 61,
			'ANDGREAT' => 31,
			"<" => 5,
			">(" => 58,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28,
			"<(" => 60
		},
		DEFAULT => -84,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'filename' => 63,
			'io_redirect' => 62,
			'cmd_suffix' => 132
		}
	},
	{#State 99
		ACTIONS => {
			'Then' => 133
		}
	},
	{#State 100
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 134,
			'while_clause' => 53
		}
	},
	{#State 101
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 135,
			'newline_list' => 123
		}
	},
	{#State 102
		DEFAULT => -41
	},
	{#State 103
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 136,
			'newline_list' => 123
		}
	},
	{#State 104
		DEFAULT => -117
	},
	{#State 105
		ACTIONS => {
			"|" => 103
		},
		DEFAULT => -7
	},
	{#State 106
		DEFAULT => -111
	},
	{#State 107
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 137,
			'newline_list' => 123
		}
	},
	{#State 108
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 138,
			'newline_list' => 123
		}
	},
	{#State 109
		ACTIONS => {
			'Do' => 121,
			";" => 141,
			'NEWLINE' => 44
		},
		GOTOS => {
			'newline_list' => 139,
			'sequential_sep' => 142,
			'do_group' => 140
		}
	},
	{#State 110
		ACTIONS => {
			";" => 141,
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 143,
			'newline_list' => 144,
			'sequential_sep' => 145
		}
	},
	{#State 111
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		DEFAULT => -27,
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 131,
			'while_clause' => 53
		}
	},
	{#State 112
		ACTIONS => {
			")" => 146
		}
	},
	{#State 113
		ACTIONS => {
			")" => 147
		}
	},
	{#State 114
		DEFAULT => -98
	},
	{#State 115
		DEFAULT => -94
	},
	{#State 116
		DEFAULT => -96
	},
	{#State 117
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 148,
			'newline_list' => 123
		}
	},
	{#State 118
		ACTIONS => {
			";" => 91,
			"&" => 92,
			'NEWLINE' => 44
		},
		GOTOS => {
			'newline_list' => 89,
			'separator' => 149,
			'separator_op' => 90
		}
	},
	{#State 119
		ACTIONS => {
			'WORD' => 1,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'While' => 29,
			">" => 28,
			'ANDGREAT' => 31,
			'LESSGREAT' => 36,
			'If' => 41,
			'Select' => 43,
			'DLESS' => 47,
			'Bang' => 49,
			'DGREAT' => 51,
			'For' => 54
		},
		DEFAULT => -28,
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 131,
			'while_clause' => 53
		}
	},
	{#State 120
		DEFAULT => -74
	},
	{#State 121
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 66,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 67,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'compound_list_s' => 150,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 122
		ACTIONS => {
			'Case' => 21,
			'Lbrace' => 20,
			'Until' => 10,
			"(" => 26,
			'If' => 41,
			'DPAR' => 16,
			'For' => 54,
			'Select' => 43,
			'While' => 29
		},
		GOTOS => {
			'case_clause' => 2,
			'subshell' => 34,
			'compound_command' => 152,
			'select_clause' => 50,
			'for_clause' => 22,
			'brace_group' => 12,
			'if_clause' => 39,
			'until_clause' => 27,
			'while_clause' => 53,
			'function_body' => 151
		}
	},
	{#State 123
		ACTIONS => {
			'NEWLINE' => 56
		},
		DEFAULT => -122
	},
	{#State 124
		ACTIONS => {
			")" => 153
		}
	},
	{#State 125
		DEFAULT => -81
	},
	{#State 126
		ACTIONS => {
			'In' => 155
		},
		GOTOS => {
			'in' => 154
		}
	},
	{#State 127
		DEFAULT => -23
	},
	{#State 128
		DEFAULT => -73
	},
	{#State 129
		DEFAULT => -100
	},
	{#State 130
		DEFAULT => -126
	},
	{#State 131
		ACTIONS => {
			'OR_IF' => 107,
			'AND_IF' => 108
		},
		DEFAULT => -30
	},
	{#State 132
		ACTIONS => {
			'WORD' => 114,
			'ANDGREAT' => 31,
			"<" => 5,
			">(" => 58,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28,
			"<(" => 60
		},
		DEFAULT => -83,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'filename' => 116,
			'io_redirect' => 115
		}
	},
	{#State 133
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 66,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 67,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'compound_list_s' => 156,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 134
		ACTIONS => {
			'OR_IF' => 107,
			'AND_IF' => 108
		},
		DEFAULT => -32
	},
	{#State 135
		ACTIONS => {
			'Do' => 121,
			'In' => 155
		},
		GOTOS => {
			'in' => 157,
			'do_group' => 158
		}
	},
	{#State 136
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'command' => 159,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'while_clause' => 53
		}
	},
	{#State 137
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 160,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'while_clause' => 53
		}
	},
	{#State 138
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 161,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'while_clause' => 53
		}
	},
	{#State 139
		ACTIONS => {
			'NEWLINE' => 56
		},
		DEFAULT => -129
	},
	{#State 140
		DEFAULT => -40
	},
	{#State 141
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 162,
			'newline_list' => 123
		}
	},
	{#State 142
		ACTIONS => {
			'Do' => 121
		},
		GOTOS => {
			'do_group' => 163
		}
	},
	{#State 143
		ACTIONS => {
			'Do' => 121,
			'In' => 155
		},
		GOTOS => {
			'in' => 164,
			'do_group' => 165
		}
	},
	{#State 144
		ACTIONS => {
			'NEWLINE' => 56
		},
		DEFAULT => -122
	},
	{#State 145
		ACTIONS => {
			'Do' => 121
		},
		GOTOS => {
			'do_group' => 166
		}
	},
	{#State 146
		DEFAULT => -116
	},
	{#State 147
		DEFAULT => -115
	},
	{#State 148
		ACTIONS => {
			'Case' => 21,
			'Lbrace' => 20,
			'Until' => 10,
			"(" => 26,
			'If' => 41,
			'DPAR' => 16,
			'For' => 54,
			'Select' => 43,
			'While' => 29
		},
		GOTOS => {
			'case_clause' => 2,
			'subshell' => 34,
			'compound_command' => 152,
			'select_clause' => 50,
			'for_clause' => 22,
			'brace_group' => 12,
			'if_clause' => 39,
			'until_clause' => 27,
			'while_clause' => 53,
			'function_body' => 167
		}
	},
	{#State 149
		ACTIONS => {
			'WORD' => 1,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'While' => 29,
			">" => 28,
			'ANDGREAT' => 31,
			'LESSGREAT' => 36,
			'If' => 41,
			'Select' => 43,
			'DLESS' => 47,
			'Bang' => 49,
			'DGREAT' => 51,
			'For' => 54
		},
		DEFAULT => -29,
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 131,
			'while_clause' => 53
		}
	},
	{#State 150
		ACTIONS => {
			'Done' => 168
		}
	},
	{#State 151
		DEFAULT => -76
	},
	{#State 152
		ACTIONS => {
			'ANDGREAT' => 31,
			"<" => 5,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28
		},
		DEFAULT => -78,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'io_redirect' => 87,
			'redirect_list' => 169
		}
	},
	{#State 153
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 170,
			'newline_list' => 123
		}
	},
	{#State 154
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 171,
			'newline_list' => 123
		}
	},
	{#State 155
		DEFAULT => -42
	},
	{#State 156
		ACTIONS => {
			'Elif' => 172,
			'Else' => 175,
			'Fi' => 173
		},
		GOTOS => {
			'else_part' => 174
		}
	},
	{#State 157
		ACTIONS => {
			'WORD' => 176
		},
		GOTOS => {
			'wordlist' => 177
		}
	},
	{#State 158
		DEFAULT => -33
	},
	{#State 159
		DEFAULT => -9
	},
	{#State 160
		DEFAULT => -5
	},
	{#State 161
		DEFAULT => -4
	},
	{#State 162
		DEFAULT => -128
	},
	{#State 163
		DEFAULT => -39
	},
	{#State 164
		ACTIONS => {
			'WORD' => 176,
			";" => 141,
			'NEWLINE' => 44
		},
		GOTOS => {
			'newline_list' => 139,
			'wordlist' => 178,
			'sequential_sep' => 179
		}
	},
	{#State 165
		DEFAULT => -35
	},
	{#State 166
		DEFAULT => -36
	},
	{#State 167
		DEFAULT => -77
	},
	{#State 168
		DEFAULT => -82
	},
	{#State 169
		ACTIONS => {
			'ANDGREAT' => 31,
			"<" => 5,
			'LESSGREAT' => 36,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'LESSAND' => 19,
			'DLESS' => 47,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DGREAT' => 51,
			">" => 28
		},
		DEFAULT => -79,
		GOTOS => {
			'io_here' => 37,
			'io_file' => 32,
			'io_redirect' => 129
		}
	},
	{#State 170
		ACTIONS => {
			'Case' => 21,
			'Lbrace' => 20,
			'Until' => 10,
			"(" => 26,
			'If' => 41,
			'DPAR' => 16,
			'For' => 54,
			'Select' => 43,
			'While' => 29
		},
		GOTOS => {
			'case_clause' => 2,
			'subshell' => 34,
			'compound_command' => 152,
			'select_clause' => 50,
			'for_clause' => 22,
			'brace_group' => 12,
			'if_clause' => 39,
			'until_clause' => 27,
			'while_clause' => 53,
			'function_body' => 180
		}
	},
	{#State 171
		ACTIONS => {
			'WORD' => 181,
			"(" => 186,
			'Esac' => 185
		},
		GOTOS => {
			'case_item' => 182,
			'pattern' => 190,
			'case_list_ns' => 184,
			'OPTIONAL-1' => 183,
			'case_item_ns' => 189,
			'pattern_list' => 187,
			'case_list' => 188
		}
	},
	{#State 172
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 66,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 67,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'compound_list_s' => 191,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 173
		DEFAULT => -69
	},
	{#State 174
		ACTIONS => {
			'Fi' => 192
		}
	},
	{#State 175
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 66,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 67,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'compound_list_s' => 193,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 176
		DEFAULT => -44
	},
	{#State 177
		ACTIONS => {
			'WORD' => 194,
			";" => 141,
			'NEWLINE' => 44
		},
		GOTOS => {
			'newline_list' => 139,
			'sequential_sep' => 195
		}
	},
	{#State 178
		ACTIONS => {
			'WORD' => 194,
			";" => 141,
			'NEWLINE' => 44
		},
		GOTOS => {
			'newline_list' => 139,
			'sequential_sep' => 196
		}
	},
	{#State 179
		ACTIONS => {
			'Do' => 121
		},
		GOTOS => {
			'do_group' => 197
		}
	},
	{#State 180
		DEFAULT => -75
	},
	{#State 181
		DEFAULT => -64
	},
	{#State 182
		DEFAULT => -51
	},
	{#State 183
		ACTIONS => {
			"(" => 198
		}
	},
	{#State 184
		ACTIONS => {
			'Esac' => 199
		}
	},
	{#State 185
		DEFAULT => -47
	},
	{#State 186
		ACTIONS => {
			'WORD' => 181
		},
		DEFAULT => -61,
		GOTOS => {
			'pattern' => 190,
			'OPTIONAL-1' => 183,
			'pattern_list' => 200
		}
	},
	{#State 187
		ACTIONS => {
			"|" => 201,
			")" => 202
		}
	},
	{#State 188
		ACTIONS => {
			'WORD' => 181,
			"(" => 186,
			'Esac' => 204
		},
		GOTOS => {
			'case_item' => 203,
			'pattern' => 190,
			'OPTIONAL-1' => 183,
			'case_item_ns' => 205,
			'pattern_list' => 187
		}
	},
	{#State 189
		DEFAULT => -49
	},
	{#State 190
		ACTIONS => {
			"(" => -60
		},
		DEFAULT => -66
	},
	{#State 191
		ACTIONS => {
			'Then' => 206
		}
	},
	{#State 192
		DEFAULT => -68
	},
	{#State 193
		DEFAULT => -72
	},
	{#State 194
		DEFAULT => -43
	},
	{#State 195
		ACTIONS => {
			'Do' => 121
		},
		GOTOS => {
			'do_group' => 207
		}
	},
	{#State 196
		ACTIONS => {
			'Do' => 121
		},
		GOTOS => {
			'do_group' => 208
		}
	},
	{#State 197
		DEFAULT => -37
	},
	{#State 198
		ACTIONS => {
			'WORD' => 181
		},
		DEFAULT => -61,
		GOTOS => {
			'pattern' => 190,
			'OPTIONAL-1' => 183,
			'pattern_list' => 209
		}
	},
	{#State 199
		DEFAULT => -46
	},
	{#State 200
		ACTIONS => {
			"|" => 201,
			")" => 210
		}
	},
	{#State 201
		ACTIONS => {
			'WORD' => 181
		},
		DEFAULT => -61,
		GOTOS => {
			'pattern' => 211,
			'OPTIONAL-1' => 183
		}
	},
	{#State 202
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DSEMI' => -123,
			'Esac' => -123,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'linebreak' => 212,
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 213,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 215,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'compound_list' => 214,
			'function_definition' => 17,
			'compound_list_s' => 216,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 203
		DEFAULT => -50
	},
	{#State 204
		DEFAULT => -45
	},
	{#State 205
		DEFAULT => -48
	},
	{#State 206
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 66,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 67,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'compound_list_s' => 217,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 207
		DEFAULT => -34
	},
	{#State 208
		DEFAULT => -38
	},
	{#State 209
		ACTIONS => {
			"|" => 201,
			")" => 218
		}
	},
	{#State 210
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 44,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DSEMI' => -123,
			'Esac' => -123,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'linebreak' => 219,
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'newline_list' => 213,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 215,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'compound_list' => 220,
			'function_definition' => 17,
			'compound_list_s' => 221,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 211
		ACTIONS => {
			"(" => -60
		},
		DEFAULT => -67
	},
	{#State 212
		ACTIONS => {
			'DSEMI' => 222
		},
		DEFAULT => -52
	},
	{#State 213
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'error' => 42,
			'DPAR' => 16,
			'Select' => 43,
			'NEWLINE' => 56,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'DSEMI' => -122,
			'Esac' => -122,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'term' => 223,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 52,
			'while_clause' => 53
		}
	},
	{#State 214
		ACTIONS => {
			'DSEMI' => 224
		}
	},
	{#State 215
		ACTIONS => {
			";" => 91,
			"&" => 92,
			'NEWLINE' => 44
		},
		DEFAULT => -24,
		GOTOS => {
			'newline_list' => 89,
			'separator' => 225,
			'separator_op' => 90
		}
	},
	{#State 216
		DEFAULT => -53
	},
	{#State 217
		ACTIONS => {
			'Elif' => 172,
			'Else' => 175
		},
		DEFAULT => -70,
		GOTOS => {
			'else_part' => 226
		}
	},
	{#State 218
		ACTIONS => {
			'WORD' => 181,
			"(" => -61
		},
		DEFAULT => -63,
		GOTOS => {
			'OPTIONAL-2' => 227,
			'pattern' => 228,
			'OPTIONAL-1' => 183
		}
	},
	{#State 219
		ACTIONS => {
			'DSEMI' => 229
		},
		DEFAULT => -54
	},
	{#State 220
		ACTIONS => {
			'DSEMI' => 230
		}
	},
	{#State 221
		DEFAULT => -55
	},
	{#State 222
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 231,
			'newline_list' => 123
		}
	},
	{#State 223
		ACTIONS => {
			";" => 91,
			"&" => 92,
			'NEWLINE' => 44
		},
		DEFAULT => -25,
		GOTOS => {
			'newline_list' => 89,
			'separator' => 232,
			'separator_op' => 90
		}
	},
	{#State 224
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 233,
			'newline_list' => 123
		}
	},
	{#State 225
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'Esac' => -28,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		DEFAULT => -26,
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 131,
			'while_clause' => 53
		}
	},
	{#State 226
		DEFAULT => -71
	},
	{#State 227
		DEFAULT => -65
	},
	{#State 228
		ACTIONS => {
			"(" => -60
		},
		DEFAULT => -62
	},
	{#State 229
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 234,
			'newline_list' => 123
		}
	},
	{#State 230
		ACTIONS => {
			'NEWLINE' => 44
		},
		DEFAULT => -123,
		GOTOS => {
			'linebreak' => 235,
			'newline_list' => 123
		}
	},
	{#State 231
		DEFAULT => -56
	},
	{#State 232
		ACTIONS => {
			'WORD' => 1,
			'ANDGREAT' => 31,
			'ASSIGNMENT_WORD' => 6,
			"<" => 5,
			'Until' => 10,
			'Function' => 11,
			'LESSGREAT' => 36,
			'If' => 41,
			'TLESS' => 13,
			'IO_NUMBER' => 14,
			'DPAR' => 16,
			'Select' => 43,
			'DLESS' => 47,
			'LESSAND' => 19,
			'Lbrace' => 20,
			'Case' => 21,
			'Bang' => 49,
			'CLOBBER' => 23,
			'DLESSDASH' => 24,
			'GREATAND' => 25,
			'Esac' => -29,
			"(" => 26,
			'DGREAT' => 51,
			'For' => 54,
			'While' => 29,
			">" => 28
		},
		DEFAULT => -27,
		GOTOS => {
			'case_clause' => 2,
			'compound_command' => 33,
			'subshell' => 34,
			'io_file' => 32,
			'io_redirect' => 7,
			'fname' => 9,
			'cmd_word' => 8,
			'simple_command' => 38,
			'io_here' => 37,
			'if_clause' => 39,
			'brace_group' => 12,
			'cmd_prefix' => 40,
			'function_definition' => 17,
			'pipeline' => 18,
			'pipe_sequence' => 46,
			'command' => 45,
			'NAME' => 48,
			'select_clause' => 50,
			'for_clause' => 22,
			'until_clause' => 27,
			'and_or' => 131,
			'while_clause' => 53
		}
	},
	{#State 233
		DEFAULT => -57
	},
	{#State 234
		DEFAULT => -58
	},
	{#State 235
		DEFAULT => -59
	}
],
    yyrules  =>
[
	[#Rule _SUPERSTART
		 '$start', 2, undef
#line 6979 ShParser.pm
	],
	[#Rule start_1
		 'start', 1,
sub {
#line 30 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYBuildAST }
#line 6986 ShParser.pm
	],
	[#Rule start_2
		 'start', 1,
sub {
#line 30 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYBuildAST }
#line 6993 ShParser.pm
	],
	[#Rule and_or_3
		 'and_or', 1,
sub {
#line 136 "src/sh.yp"
 undef; }
#line 7000 ShParser.pm
	],
	[#Rule and_or_4
		 'and_or', 4,
sub {
#line 137 "src/sh.yp"
 undef; }
#line 7007 ShParser.pm
	],
	[#Rule and_or_5
		 'and_or', 4,
sub {
#line 138 "src/sh.yp"
 undef; }
#line 7014 ShParser.pm
	],
	[#Rule pipeline_6
		 'pipeline', 1,
sub {
#line 140 "src/sh.yp"
 undef; }
#line 7021 ShParser.pm
	],
	[#Rule pipeline_7
		 'pipeline', 2,
sub {
#line 141 "src/sh.yp"
 undef; }
#line 7028 ShParser.pm
	],
	[#Rule pipe_sequence_8
		 'pipe_sequence', 1,
sub {
#line 143 "src/sh.yp"
 undef; }
#line 7035 ShParser.pm
	],
	[#Rule pipe_sequence_9
		 'pipe_sequence', 4,
sub {
#line 144 "src/sh.yp"
 undef; }
#line 7042 ShParser.pm
	],
	[#Rule command_10
		 'command', 1,
sub {
#line 146 "src/sh.yp"
 undef; }
#line 7049 ShParser.pm
	],
	[#Rule command_11
		 'command', 1,
sub {
#line 147 "src/sh.yp"
 undef; }
#line 7056 ShParser.pm
	],
	[#Rule command_12
		 'command', 2,
sub {
#line 148 "src/sh.yp"
 undef; }
#line 7063 ShParser.pm
	],
	[#Rule command_13
		 'command', 1,
sub {
#line 149 "src/sh.yp"
 undef; }
#line 7070 ShParser.pm
	],
	[#Rule compound_command_14
		 'compound_command', 1,
sub {
#line 151 "src/sh.yp"
 undef; }
#line 7077 ShParser.pm
	],
	[#Rule compound_command_15
		 'compound_command', 1,
sub {
#line 152 "src/sh.yp"
 Hooked($_[0], 'DPAR', $_[1]); undef; }
#line 7084 ShParser.pm
	],
	[#Rule compound_command_16
		 'compound_command', 1,
sub {
#line 153 "src/sh.yp"
 undef; }
#line 7091 ShParser.pm
	],
	[#Rule compound_command_17
		 'compound_command', 1,
sub {
#line 154 "src/sh.yp"
 undef; }
#line 7098 ShParser.pm
	],
	[#Rule compound_command_18
		 'compound_command', 1,
sub {
#line 155 "src/sh.yp"
 undef; }
#line 7105 ShParser.pm
	],
	[#Rule compound_command_19
		 'compound_command', 1,
sub {
#line 156 "src/sh.yp"
 undef; }
#line 7112 ShParser.pm
	],
	[#Rule compound_command_20
		 'compound_command', 1,
sub {
#line 157 "src/sh.yp"
 undef; }
#line 7119 ShParser.pm
	],
	[#Rule compound_command_21
		 'compound_command', 1,
sub {
#line 158 "src/sh.yp"
 undef; }
#line 7126 ShParser.pm
	],
	[#Rule compound_command_22
		 'compound_command', 1,
sub {
#line 159 "src/sh.yp"
 undef; }
#line 7133 ShParser.pm
	],
	[#Rule subshell_23
		 'subshell', 3,
sub {
#line 161 "src/sh.yp"
 undef; }
#line 7140 ShParser.pm
	],
	[#Rule compound_list_24
		 'compound_list', 1,
sub {
#line 163 "src/sh.yp"
 undef; }
#line 7147 ShParser.pm
	],
	[#Rule compound_list_25
		 'compound_list', 2,
sub {
#line 164 "src/sh.yp"
 undef; }
#line 7154 ShParser.pm
	],
	[#Rule compound_list_26
		 'compound_list', 2,
sub {
#line 165 "src/sh.yp"
 undef; }
#line 7161 ShParser.pm
	],
	[#Rule compound_list_27
		 'compound_list', 3,
sub {
#line 166 "src/sh.yp"
 undef; }
#line 7168 ShParser.pm
	],
	[#Rule compound_list_s_28
		 'compound_list_s', 2,
sub {
#line 168 "src/sh.yp"
 undef; }
#line 7175 ShParser.pm
	],
	[#Rule compound_list_s_29
		 'compound_list_s', 3,
sub {
#line 169 "src/sh.yp"
 undef; }
#line 7182 ShParser.pm
	],
	[#Rule term_30
		 'term', 3,
sub {
#line 171 "src/sh.yp"
 undef; }
#line 7189 ShParser.pm
	],
	[#Rule term_31
		 'term', 1,
sub {
#line 172 "src/sh.yp"
 undef; }
#line 7196 ShParser.pm
	],
	[#Rule term_32
		 'term', 3,
sub {
#line 173 "src/sh.yp"
 $_[0]->YYErrok; undef; }
#line 7203 ShParser.pm
	],
	[#Rule select_clause_33
		 'select_clause', 4,
sub {
#line 175 "src/sh.yp"
 Hooked($_[0], 'SELECT', $_[1]); undef; }
#line 7210 ShParser.pm
	],
	[#Rule select_clause_34
		 'select_clause', 7,
sub {
#line 176 "src/sh.yp"
 Hooked($_[0], 'SELECT', $_[1]); undef; }
#line 7217 ShParser.pm
	],
	[#Rule for_clause_35
		 'for_clause', 4,
sub {
#line 178 "src/sh.yp"
 undef; }
#line 7224 ShParser.pm
	],
	[#Rule for_clause_36
		 'for_clause', 4,
sub {
#line 179 "src/sh.yp"
 Hooked($_[0], 'FOR_VARSEMI', $_[2]); undef; }
#line 7231 ShParser.pm
	],
	[#Rule for_clause_37
		 'for_clause', 6,
sub {
#line 180 "src/sh.yp"
 undef; }
#line 7238 ShParser.pm
	],
	[#Rule for_clause_38
		 'for_clause', 7,
sub {
#line 181 "src/sh.yp"
 undef; }
#line 7245 ShParser.pm
	],
	[#Rule for_clause_39
		 'for_clause', 4,
sub {
#line 182 "src/sh.yp"
 Hooked($_[0], 'LOOP_DPAR', [$_[1][0],['for']]); undef; }
#line 7252 ShParser.pm
	],
	[#Rule for_clause_40
		 'for_clause', 3,
sub {
#line 183 "src/sh.yp"
 Hooked($_[0], 'LOOP_DPAR', [$_[1][0],['for']]); undef; }
#line 7259 ShParser.pm
	],
	[#Rule name_41
		 'name', 1,
sub {
#line 185 "src/sh.yp"
 return $_[1]; }
#line 7266 ShParser.pm
	],
	[#Rule in_42
		 'in', 1,
sub {
#line 187 "src/sh.yp"
 return $_[1]; }
#line 7273 ShParser.pm
	],
	[#Rule wordlist_43
		 'wordlist', 2,
sub {
#line 189 "src/sh.yp"
 undef; }
#line 7280 ShParser.pm
	],
	[#Rule wordlist_44
		 'wordlist', 1,
sub {
#line 190 "src/sh.yp"
 undef; }
#line 7287 ShParser.pm
	],
	[#Rule case_clause_45
		 'case_clause', 7,
sub {
#line 192 "src/sh.yp"
 undef; }
#line 7294 ShParser.pm
	],
	[#Rule case_clause_46
		 'case_clause', 7,
sub {
#line 193 "src/sh.yp"
 undef; }
#line 7301 ShParser.pm
	],
	[#Rule case_clause_47
		 'case_clause', 6,
sub {
#line 194 "src/sh.yp"
 undef; }
#line 7308 ShParser.pm
	],
	[#Rule case_list_ns_48
		 'case_list_ns', 2,
sub {
#line 196 "src/sh.yp"
 undef; }
#line 7315 ShParser.pm
	],
	[#Rule case_list_ns_49
		 'case_list_ns', 1,
sub {
#line 197 "src/sh.yp"
 undef; }
#line 7322 ShParser.pm
	],
	[#Rule case_list_50
		 'case_list', 2,
sub {
#line 199 "src/sh.yp"
 undef; }
#line 7329 ShParser.pm
	],
	[#Rule case_list_51
		 'case_list', 1,
sub {
#line 200 "src/sh.yp"
 undef; }
#line 7336 ShParser.pm
	],
	[#Rule case_item_ns_52
		 'case_item_ns', 3,
sub {
#line 202 "src/sh.yp"
 undef; }
#line 7343 ShParser.pm
	],
	[#Rule case_item_ns_53
		 'case_item_ns', 3,
sub {
#line 203 "src/sh.yp"
 undef; }
#line 7350 ShParser.pm
	],
	[#Rule case_item_ns_54
		 'case_item_ns', 4,
sub {
#line 204 "src/sh.yp"
 undef; }
#line 7357 ShParser.pm
	],
	[#Rule case_item_ns_55
		 'case_item_ns', 4,
sub {
#line 205 "src/sh.yp"
 undef; }
#line 7364 ShParser.pm
	],
	[#Rule case_item_56
		 'case_item', 5,
sub {
#line 207 "src/sh.yp"
 undef; }
#line 7371 ShParser.pm
	],
	[#Rule case_item_57
		 'case_item', 5,
sub {
#line 208 "src/sh.yp"
 undef; }
#line 7378 ShParser.pm
	],
	[#Rule case_item_58
		 'case_item', 6,
sub {
#line 209 "src/sh.yp"
 undef; }
#line 7385 ShParser.pm
	],
	[#Rule case_item_59
		 'case_item', 6,
sub {
#line 210 "src/sh.yp"
 undef; }
#line 7392 ShParser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-1', 1,
sub {
#line 213 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 7399 ShParser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-1', 0,
sub {
#line 213 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 7406 ShParser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-2', 1,
sub {
#line 213 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYActionforT_single }
#line 7413 ShParser.pm
	],
	[#Rule _OPTIONAL
		 'OPTIONAL-2', 0,
sub {
#line 213 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYActionforT_empty }
#line 7420 ShParser.pm
	],
	[#Rule pattern_64
		 'pattern', 1,
sub {
#line 212 "src/sh.yp"
 undef; }
#line 7427 ShParser.pm
	],
	[#Rule pattern_65
		 'pattern', 5,
sub {
#line 213 "src/sh.yp"
 Hooked($_[0], 'EXTGLOB', $_[2], @_); undef; }
#line 7434 ShParser.pm
	],
	[#Rule pattern_list_66
		 'pattern_list', 1,
sub {
#line 215 "src/sh.yp"
 undef; }
#line 7441 ShParser.pm
	],
	[#Rule pattern_list_67
		 'pattern_list', 3,
sub {
#line 216 "src/sh.yp"
 undef; }
#line 7448 ShParser.pm
	],
	[#Rule if_clause_68
		 'if_clause', 6,
sub {
#line 218 "src/sh.yp"
 undef; }
#line 7455 ShParser.pm
	],
	[#Rule if_clause_69
		 'if_clause', 5,
sub {
#line 219 "src/sh.yp"
 undef; }
#line 7462 ShParser.pm
	],
	[#Rule else_part_70
		 'else_part', 4,
sub {
#line 221 "src/sh.yp"
 undef; }
#line 7469 ShParser.pm
	],
	[#Rule else_part_71
		 'else_part', 5,
sub {
#line 222 "src/sh.yp"
 undef; }
#line 7476 ShParser.pm
	],
	[#Rule else_part_72
		 'else_part', 2,
sub {
#line 223 "src/sh.yp"
 undef; }
#line 7483 ShParser.pm
	],
	[#Rule while_clause_73
		 'while_clause', 3,
sub {
#line 230 "src/sh.yp"
 undef; }
#line 7490 ShParser.pm
	],
	[#Rule until_clause_74
		 'until_clause', 3,
sub {
#line 232 "src/sh.yp"
 undef; }
#line 7497 ShParser.pm
	],
	[#Rule function_definition_75
		 'function_definition', 6,
sub {
#line 234 "src/sh.yp"
 Hooked($_[0], 'BAD_FUNC_DEF', $_[2], @_); Hooked($_[0], 'FUNCTION', $_[2], @_); undef }
#line 7504 ShParser.pm
	],
	[#Rule function_definition_76
		 'function_definition', 4,
sub {
#line 235 "src/sh.yp"
 Hooked($_[0], 'BAD_FUNC_DEF', $_[2], @_); Hooked($_[0], 'FUNCTION', $_[2], @_); undef }
#line 7511 ShParser.pm
	],
	[#Rule function_definition_77
		 'function_definition', 5,
sub {
#line 236 "src/sh.yp"
 Hooked($_[0], 'FUNCTION', $_[1], @_); undef }
#line 7518 ShParser.pm
	],
	[#Rule function_body_78
		 'function_body', 1,
sub {
#line 238 "src/sh.yp"
 undef; }
#line 7525 ShParser.pm
	],
	[#Rule function_body_79
		 'function_body', 2,
sub {
#line 239 "src/sh.yp"
 undef; }
#line 7532 ShParser.pm
	],
	[#Rule fname_80
		 'fname', 1,
sub {
#line 241 "src/sh.yp"
 return $_[1]; }
#line 7539 ShParser.pm
	],
	[#Rule brace_group_81
		 'brace_group', 3,
sub {
#line 243 "src/sh.yp"
 undef; }
#line 7546 ShParser.pm
	],
	[#Rule do_group_82
		 'do_group', 3,
sub {
#line 245 "src/sh.yp"
 undef; }
#line 7553 ShParser.pm
	],
	[#Rule simple_command_83
		 'simple_command', 3,
sub {
#line 247 "src/sh.yp"
 OnCommand($_[0], $_[2], $_[3]); undef }
#line 7560 ShParser.pm
	],
	[#Rule simple_command_84
		 'simple_command', 2,
sub {
#line 248 "src/sh.yp"
 OnCommand($_[0], $_[2]); undef }
#line 7567 ShParser.pm
	],
	[#Rule simple_command_85
		 'simple_command', 1,
sub {
#line 30 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYBuildAST }
#line 7574 ShParser.pm
	],
	[#Rule simple_command_86
		 'simple_command', 2,
sub {
#line 250 "src/sh.yp"
 OnCommand($_[0], $_[1], $_[2]); undef }
#line 7581 ShParser.pm
	],
	[#Rule simple_command_87
		 'simple_command', 1,
sub {
#line 251 "src/sh.yp"
 OnCommand($_[0], $_[1]); undef }
#line 7588 ShParser.pm
	],
	[#Rule cmd_word_88
		 'cmd_word', 1,
sub {
#line 253 "src/sh.yp"
 return $_[1]; }
#line 7595 ShParser.pm
	],
	[#Rule cmd_prefix_89
		 'cmd_prefix', 1,
sub {
#line 255 "src/sh.yp"
 undef; }
#line 7602 ShParser.pm
	],
	[#Rule cmd_prefix_90
		 'cmd_prefix', 2,
sub {
#line 256 "src/sh.yp"
 undef; }
#line 7609 ShParser.pm
	],
	[#Rule cmd_prefix_91
		 'cmd_prefix', 1,
sub {
#line 257 "src/sh.yp"
 undef; }
#line 7616 ShParser.pm
	],
	[#Rule cmd_prefix_92
		 'cmd_prefix', 2,
sub {
#line 258 "src/sh.yp"
 undef; }
#line 7623 ShParser.pm
	],
	[#Rule cmd_suffix_93
		 'cmd_suffix', 1,
sub {
#line 260 "src/sh.yp"
 my $f=AST(@_); $f->{linear}=[]; return $f; }
#line 7630 ShParser.pm
	],
	[#Rule cmd_suffix_94
		 'cmd_suffix', 2,
sub {
#line 261 "src/sh.yp"
 my $f=AST(@_); $f->{linear}=$_[1]->{linear}; return  $f; }
#line 7637 ShParser.pm
	],
	[#Rule cmd_suffix_95
		 'cmd_suffix', 1,
sub {
#line 262 "src/sh.yp"
 my $f=AST(@_); $f->{linear}=[]; return $f; }
#line 7644 ShParser.pm
	],
	[#Rule cmd_suffix_96
		 'cmd_suffix', 2,
sub {
#line 263 "src/sh.yp"
 my $f=AST(@_); $f->{linear}=$_[1]->{linear}; return  $f; }
#line 7651 ShParser.pm
	],
	[#Rule cmd_suffix_97
		 'cmd_suffix', 1,
sub {
#line 264 "src/sh.yp"
 my $f=AST(@_); $f->{linear}=[$_[1]->[1]]; return $f; }
#line 7658 ShParser.pm
	],
	[#Rule cmd_suffix_98
		 'cmd_suffix', 2,
sub {
#line 265 "src/sh.yp"
 my $f=AST(@_); $f->{linear}=[@{$_[1]->{linear}}, $_[2]->[1]]; return $f; }
#line 7665 ShParser.pm
	],
	[#Rule redirect_list_99
		 'redirect_list', 1,
sub {
#line 267 "src/sh.yp"
 undef; }
#line 7672 ShParser.pm
	],
	[#Rule redirect_list_100
		 'redirect_list', 2,
sub {
#line 268 "src/sh.yp"
 undef; }
#line 7679 ShParser.pm
	],
	[#Rule io_redirect_101
		 'io_redirect', 1,
sub {
#line 270 "src/sh.yp"
 undef; }
#line 7686 ShParser.pm
	],
	[#Rule io_redirect_102
		 'io_redirect', 2,
sub {
#line 271 "src/sh.yp"
 undef; }
#line 7693 ShParser.pm
	],
	[#Rule io_redirect_103
		 'io_redirect', 1,
sub {
#line 272 "src/sh.yp"
 undef; }
#line 7700 ShParser.pm
	],
	[#Rule io_redirect_104
		 'io_redirect', 2,
sub {
#line 273 "src/sh.yp"
 undef; }
#line 7707 ShParser.pm
	],
	[#Rule io_redirect_105
		 'io_redirect', 2,
sub {
#line 274 "src/sh.yp"
 Hooked($_[0], 'ANDGREAT', $_[1]); undef }
#line 7714 ShParser.pm
	],
	[#Rule io_redirect_106
		 'io_redirect', 2,
sub {
#line 275 "src/sh.yp"
 Hooked($_[0], 'HERESTRING', $_[1]); undef }
#line 7721 ShParser.pm
	],
	[#Rule io_file_107
		 'io_file', 2,
sub {
#line 277 "src/sh.yp"
 undef; }
#line 7728 ShParser.pm
	],
	[#Rule io_file_108
		 'io_file', 2,
sub {
#line 278 "src/sh.yp"
 undef; }
#line 7735 ShParser.pm
	],
	[#Rule io_file_109
		 'io_file', 2,
sub {
#line 279 "src/sh.yp"
 undef; }
#line 7742 ShParser.pm
	],
	[#Rule io_file_110
		 'io_file', 2,
sub {
#line 280 "src/sh.yp"
 undef; }
#line 7749 ShParser.pm
	],
	[#Rule io_file_111
		 'io_file', 2,
sub {
#line 281 "src/sh.yp"
 undef; }
#line 7756 ShParser.pm
	],
	[#Rule io_file_112
		 'io_file', 2,
sub {
#line 282 "src/sh.yp"
 undef; }
#line 7763 ShParser.pm
	],
	[#Rule io_file_113
		 'io_file', 2,
sub {
#line 283 "src/sh.yp"
 undef; }
#line 7770 ShParser.pm
	],
	[#Rule filename_114
		 'filename', 1,
sub {
#line 285 "src/sh.yp"
 return $_[1]; }
#line 7777 ShParser.pm
	],
	[#Rule filename_115
		 'filename', 3,
sub {
#line 286 "src/sh.yp"
 Hooked($_[0], 'PROCSUBST', $_[1]); undef }
#line 7784 ShParser.pm
	],
	[#Rule filename_116
		 'filename', 3,
sub {
#line 287 "src/sh.yp"
 Hooked($_[0], 'PROCSUBST', $_[1]); undef }
#line 7791 ShParser.pm
	],
	[#Rule io_here_117
		 'io_here', 2,
sub {
#line 289 "src/sh.yp"
 undef; }
#line 7798 ShParser.pm
	],
	[#Rule io_here_118
		 'io_here', 2,
sub {
#line 290 "src/sh.yp"
 undef; }
#line 7805 ShParser.pm
	],
	[#Rule here_end_119
		 'here_end', 1,
sub {
#line 292 "src/sh.yp"
 return $_[1]; }
#line 7812 ShParser.pm
	],
	[#Rule newline_list_120
		 'newline_list', 1,
sub {
#line 294 "src/sh.yp"
 undef; }
#line 7819 ShParser.pm
	],
	[#Rule newline_list_121
		 'newline_list', 2,
sub {
#line 295 "src/sh.yp"
 undef; }
#line 7826 ShParser.pm
	],
	[#Rule linebreak_122
		 'linebreak', 1,
sub {
#line 297 "src/sh.yp"
 undef; }
#line 7833 ShParser.pm
	],
	[#Rule linebreak_123
		 'linebreak', 0,
sub {
#line 298 "src/sh.yp"
 undef; }
#line 7840 ShParser.pm
	],
	[#Rule separator_op_124
		 'separator_op', 1,
sub {
#line 30 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYBuildAST }
#line 7847 ShParser.pm
	],
	[#Rule separator_op_125
		 'separator_op', 1,
sub {
#line 30 "src/sh.yp"
 goto &Parse::Eyapp::Driver::YYBuildAST }
#line 7854 ShParser.pm
	],
	[#Rule separator_126
		 'separator', 2,
sub {
#line 303 "src/sh.yp"
 undef; }
#line 7861 ShParser.pm
	],
	[#Rule separator_127
		 'separator', 1,
sub {
#line 304 "src/sh.yp"
 undef; }
#line 7868 ShParser.pm
	],
	[#Rule sequential_sep_128
		 'sequential_sep', 2,
sub {
#line 306 "src/sh.yp"
 undef; }
#line 7875 ShParser.pm
	],
	[#Rule sequential_sep_129
		 'sequential_sep', 1,
sub {
#line 307 "src/sh.yp"
 undef; }
#line 7882 ShParser.pm
	],
	[#Rule NAME_130
		 'NAME', 1,
sub {
#line 309 "src/sh.yp"

        my $token = $_[1];
        if ( !is_name(serialize($token->[1])) ) {
            $_[0]->call_hook($token->[0], 'BADNAME', $token->[1]);
        }
        return $token;
    }
#line 7895 ShParser.pm
	]
],
#line 7898 ShParser.pm
    yybypass       => 0,
    yybuildingtree => 1,
    yyprefix       => '',
    yyaccessors    => {
   },
    yyconflicthandlers => {}
,
    yystateconflict => {  },
    @_,
  );
  bless($self,$class);

  $self->make_node_classes('TERMINAL', '_OPTIONAL', '_STAR_LIST', '_PLUS_LIST', 
         '_SUPERSTART', 
         'start_1', 
         'start_2', 
         'and_or_3', 
         'and_or_4', 
         'and_or_5', 
         'pipeline_6', 
         'pipeline_7', 
         'pipe_sequence_8', 
         'pipe_sequence_9', 
         'command_10', 
         'command_11', 
         'command_12', 
         'command_13', 
         'compound_command_14', 
         'compound_command_15', 
         'compound_command_16', 
         'compound_command_17', 
         'compound_command_18', 
         'compound_command_19', 
         'compound_command_20', 
         'compound_command_21', 
         'compound_command_22', 
         'subshell_23', 
         'compound_list_24', 
         'compound_list_25', 
         'compound_list_26', 
         'compound_list_27', 
         'compound_list_s_28', 
         'compound_list_s_29', 
         'term_30', 
         'term_31', 
         'term_32', 
         'select_clause_33', 
         'select_clause_34', 
         'for_clause_35', 
         'for_clause_36', 
         'for_clause_37', 
         'for_clause_38', 
         'for_clause_39', 
         'for_clause_40', 
         'name_41', 
         'in_42', 
         'wordlist_43', 
         'wordlist_44', 
         'case_clause_45', 
         'case_clause_46', 
         'case_clause_47', 
         'case_list_ns_48', 
         'case_list_ns_49', 
         'case_list_50', 
         'case_list_51', 
         'case_item_ns_52', 
         'case_item_ns_53', 
         'case_item_ns_54', 
         'case_item_ns_55', 
         'case_item_56', 
         'case_item_57', 
         'case_item_58', 
         'case_item_59', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         '_OPTIONAL', 
         'pattern_64', 
         'pattern_65', 
         'pattern_list_66', 
         'pattern_list_67', 
         'if_clause_68', 
         'if_clause_69', 
         'else_part_70', 
         'else_part_71', 
         'else_part_72', 
         'while_clause_73', 
         'until_clause_74', 
         'function_definition_75', 
         'function_definition_76', 
         'function_definition_77', 
         'function_body_78', 
         'function_body_79', 
         'fname_80', 
         'brace_group_81', 
         'do_group_82', 
         'simple_command_83', 
         'simple_command_84', 
         'simple_command_85', 
         'simple_command_86', 
         'simple_command_87', 
         'cmd_word_88', 
         'cmd_prefix_89', 
         'cmd_prefix_90', 
         'cmd_prefix_91', 
         'cmd_prefix_92', 
         'cmd_suffix_93', 
         'cmd_suffix_94', 
         'cmd_suffix_95', 
         'cmd_suffix_96', 
         'cmd_suffix_97', 
         'cmd_suffix_98', 
         'redirect_list_99', 
         'redirect_list_100', 
         'io_redirect_101', 
         'io_redirect_102', 
         'io_redirect_103', 
         'io_redirect_104', 
         'io_redirect_105', 
         'io_redirect_106', 
         'io_file_107', 
         'io_file_108', 
         'io_file_109', 
         'io_file_110', 
         'io_file_111', 
         'io_file_112', 
         'io_file_113', 
         'filename_114', 
         'filename_115', 
         'filename_116', 
         'io_here_117', 
         'io_here_118', 
         'here_end_119', 
         'newline_list_120', 
         'newline_list_121', 
         'linebreak_122', 
         'linebreak_123', 
         'separator_op_124', 
         'separator_op_125', 
         'separator_126', 
         'separator_127', 
         'sequential_sep_128', 
         'sequential_sep_129', 
         'NAME_130', );
  $self;
}

#line 318 "src/sh.yp"

# Tail section

sub AST {
	my $parser = shift;
	return $parser->YYBuildAST(@_);
}

sub call_hook {
	my $self = shift;
	my $linenum = shift;
	my $hook_name = shift;
	
	my $hook_func = $self->YYData->{HOOKS}{$hook_name};
	if ( !defined $hook_func ) {
		return undef;
	}

	if ( defined $self->YYData->{LINESHIFT} ) {
		$linenum += $self->YYData->{LINESHIFT}; # For parsing of subscripts
	}
	
	$self->YYData->{HOOK_INFO}{FILENAME} = $self->YYData->{FILENAME};
	$self->YYData->{HOOK_INFO}{LINENO} = $linenum;
	
	# $linenum may be undefined in case of syntax error
	
	return &$hook_func($self, $hook_name, @_);
}

sub OnCommand {
	my $parser = shift;
	
	my ($linenum) = @{ $_[0] };
	my @params = ();
	if ( defined $_[1] ) {
		if ( defined $_[1]->{'linear'} ) {
			@params = @{$_[1]->{'linear'}};
		}
	}
	$parser->call_hook($linenum, 'COMMAND', $_[0], @params);
	
	return $parser->YYBuildAST(@_);
}

sub Hooked {
	my $parser = shift;
	my $hook = shift;
	my $tok = shift;
	
	my ($linenum, $struct) = @$tok;
	
	$parser->call_hook($linenum, $hook, $struct);
	
	return $parser->YYBuildAST(@_);
}

#-----------------------------------------------------------------------

sub limit_len {
	my ($line) = @_;
	
	$line =~ s/\s*[\r\n].*//s; # leave only the first line
	
	if ( length($line) > 120 ) {
		return substr($line, 0,100);
	}
	
	return $line;
}

sub serialize {
	my ($arr) = @_;
	
	return $arr if ref($arr) eq '';
	
	my $res = "";
	
	foreach my $elem ( @$arr ) {
		my $ref = ref $elem;
		
		if ( $ref eq "" ) {
			$res .= $elem;
		}
		elsif ( $ref eq "ARRAY" ) {
			$res .= serialize($elem);
		}
	}
	return $res;
}

sub unquote {
	my ($arr) = @_;
	
	( ref($arr) eq 'ARRAY' ) or die;
	
	my $res = "";
	
	foreach my $elem ( @$arr ) {
		my $ref = ref $elem;
		
		if ( $ref eq "" ) {
			$res .= $elem;
		}
		elsif ( $ref eq "ARRAY" ) {
			# make a copy
			my $copy = [@$elem];
			
			# remove quotes
			my $q = shift @$copy;
			pop @$copy;
			
			if ( $q eq "" || $q eq "'" || $q eq '"' ) {
				my $unquoted = unquote($copy);
				if ( not defined $unquoted ) {
					return undef;
				}
				
				$res .= $unquoted;
			}
			elsif ( $q eq '\\' ) {
				$res .= $copy->[0];
			}
			else {
				return undef;
			}
		}
	}
	
	return $res;
}

## The shell shall read its input in terms of lines from a file,
## from a terminal in the case of an interactive shell, or from
## a string in the case of sh -c or system().
## The input lines can be of unlimited length.
## These lines shall be parsed using two major modes:
## ordinary token recognition and processing of here-documents.

sub read_line_sub {
	my ($self) = @_;
	
	my $s = "";
	if ( $self->YYData->{INPUT} =~ s/(\G.*(\n|\z))// ) {
		$s = $1;
	}
	return undef if $s eq "";
	
	$self->YYData->{LINENO}++;
	
	return $s;
}

sub read_line {
	my ($self) = @_;
	
	# Read a new line
	my $line = $self->read_line_sub();
	
	if ( $line && $line =~ m/\r\n$/ ) {
		$self->call_hook($self->YYData->{LINENO}, "CRLF", $line);
		$line =~ s/\r//g;
	}
	
	$self->YYData->{LAST_LINE} = $line;
	
	return $line;
}

my $expect_heredoc = 0;

my @operator_lexems = qw!
		&&  ||  ;;  (  )
		<<  >>  <<-  <<<  <&  >&  &>  <>  >|  <(  >(
	!;

my $re_operators = "(".(join "|", map { my $a=$_; $a=~s/([\(\)\[\]\|\\\/\+\?\.\*])/\\$1/g; $a } @operator_lexems).")";

my %op_parts = ();
foreach my $op ( @operator_lexems ) {
	while ( $op ne "" ) {
		$op_parts{$op} = 1;
		$op =~ s/.\z//s;
	}
}

my $re_op_parts = "(".(join "|", map { my $a=$_; $a=~s/([\(\)\[\]\|\\\/\+\?\.\*])/\\$1/g; $a } keys %op_parts).")";


sub read_token {
	my ($self, $line, $in_quote) = @_;
	
	if ( !defined $line ) {
		$line = \$self->YYData->{LINE};
	}
	
	# The shell shall read sufficient input to determine the end of the unit
	# to be expanded (as explained in the cited sections).
	# While processing the characters, if instances of expansions or quoting are found
	# nested within the substitution, the shell shall recursively process them in the manner
	# specified for the construct that is found. The characters found from the beginning
	# of the substitution to its end, allowing for any recursion necessary to recognize
	# embedded constructs, shall be included unmodified in the result token, including
	# any embedded or enclosing substitution operators or quotes. The token shall not be
	# delimited by the end of the substitution.
	
	my $token = ""; # The current token
	my $part = ""; # A part of the current token
	
	local *discard_char = sub {
		if ( $$line =~ s/^(.)//s ) { # read one char
			return $1;
		}
		return '';
	};
	local *shift_char = sub {
		if ( $$line =~ s/^(.)//s ) { # read one char
			$part .= $1;
			$token .= $1;
			return $1;
		}
		return '';
	};
	
	# Use stack as a common aproach to avoid recursion.
	my @stack = ();
	
	# Current mode: '\\', '', '$(', '$((', '((', '[[', '?(', '${', '$[', '=(', '`', '$', "'", '"', '<<'
	my $quotmode = ($in_quote or '');
	
	my $result = [];
	
	my $par_count = 0; # count parentheses
	my $no_exp_hook = 0; # Don't call expansion hook to avoid double error messages.
	
	# Store the context, change the mode
	local *set_quotmode = sub {
		my ($newquotmode, $qq) = @_;
		if ( !defined $qq ) { $qq = $newquotmode; }
		
		if ( $part ne "" ) {
			push @$result, $part;
			$part = "";
		}
		
		# Store values
		my $record = {
			QUOTMODE => $quotmode,
			RESULT => $result,
			PAR_COUNT => $par_count,
			TOKEN => $token,
			NOEXPHOOK => $no_exp_hook,
		};
		push @stack, $record;
		
		# Reset variables for new mode
		$quotmode = $newquotmode;
		$result = [$qq,];
		$token = ""; $part = "";
		$par_count = 0;
		$no_exp_hook = 1 if $newquotmode eq '$(';
	};
	
	# Pop the stack, restore the previous mode.
	local *off_quotmode = sub {
		my ($closing_quote) = @_;
		
		if ( $part ne "" ) {
			push @$result, $part;
			$part = "";
		}
		push @$result, $closing_quote;
		
		if ( !@stack ) {
			$self->_Error("Stack depletion. Token: '$token'. Line: ".$self->YYData->{LINENO}." '$$line'");
			$quotmode = undef;
			return;
		}
		
		$no_exp_hook = $stack[-1]{NOEXPHOOK};
		
		if ( $quotmode eq '$' && @$result == 2 ) { # empty $ param - just a $ character
			$result = '$';
		} 
		else {
			# do .. while(0) block
			{
				last if ( $quotmode eq '\\' || $quotmode eq '"' || $quotmode eq "'" );
				last if $no_exp_hook;
				$self->call_hook($self->YYData->{LINENO}, "EXPANSION", $result);
			}
		}
		
		# Pop the stack
		my $record = pop @stack;
		$quotmode = $record->{QUOTMODE};
		push @{$record->{RESULT}}, $result;
		$result = $record->{RESULT};
		$par_count = $record->{PAR_COUNT};
		$token = $record->{TOKEN}.serialize($result->[-1]);
		# $no_exp_hook has already been restored above
		$part = "";
	};
	
	# Checks that are common for all modes.
	# Returns 1 if should do 'next' in the main loop.
	
	local *check_exppar = sub {
		# If the current character is an unquoted '$' or '`', the shell shall identify
		# the start of any candidates for parameter expansion, command substitution,
		# or arithmetic expansion from their introductory unquoted character sequences:
		# '$' or '${', '$(' or '`', and '$((', respectively.
		# [ Also '$[' ]
		
		#					$((	  $(	 ${	$[	 `	$
		if ( $$line =~ s/^( \$\(\( | \$\( | \${ | \$\[ | \` | \$ )//x ) {
			set_quotmode($1);
			return 1;
		}
		return 0;
	};
	
	local *check_qq = sub {
		# If the current character is single-quote, or double-quote
		# and it is not quoted, it shall affect quoting for subsequent characters
		# up to the end of the quoted text.
		if ( $$line =~ /^(['"])/ ) { # ' or  "
			discard_char();
			set_quotmode($1);
			return 1;
		}
		return 0;
	};
	
	# The main cycle. Read the line char by char
	while ( 1 ) {
		if ( !defined $$line || $$line eq "" ) {
			unless ( $self->YYData->{NO_READLINE} ) {
				# Read the next line if needed
				$$line = $self->read_line();
			}
			
			# If the end of input is recognized, the current token shall be delimited.
			if ( !defined $$line || $$line eq "" ) {
				last; # delimit
			}
		}
		
		if ( !defined $quotmode ) {
			last;
		}
				
		my $nc = ""; # The next (following) character
		if ( $$line =~ m/^(.)/s ) { # read one char
			$nc = $1;
		}
		
		## -- FOR ALL MODES --
		
		if ( $nc eq '\\' ) {
			# Check for \<newline>.
			# If a <newline> follows the backslash, the shell shall
			# interpret this as line continuation.
			$$line =~ s/^\\\n//s and redo;
		}
		
		## -- MODES --
		
		# Backslash
		if ( $quotmode eq '\\' ) { # '\'
			# A backslash that is not quoted shall preserve the literal value
			# of the following character.
			shift_char();
			off_quotmode('');
			next;
		} # end of quotmode '\' (backslash)
		
		# Unescaped Mode
		elsif ( $quotmode eq '' ) {
			# check quotmodes '((', '[['
			if ( $token eq '' && $$line =~ s/^(\(\(|\[\[)// ) {
				set_quotmode($1);
				next;
			}
			if ( $token =~ m/^(\(\(|\[\[)/ ) {
				last;
			}
			
			# If the previous character was used as part of an operator...
			if ( $token =~ m/^$re_op_parts\z/s ) {
				# ... and the current character is not quoted and can be used
				# with the current characters to form an operator,
				if ( ($token.$nc) =~ m/^$re_operators\z/s ) {
					# it shall be used as part of that (operator) token.
					shift_char();
					next;
				} else {
					# If the previous character was used as part of an operator and the current
					# character cannot be used with the current characters to form an operator,
					# the operator containing the previous character shall be delimited.
					
					last; # delimit the token
				}
			}
			
			# If the current character is not quoted and can be used as the first
			# character of a new operator, the current token (if any) shall be delimited.
			# The current character shall be used as the beginning of the next (operator) token.
			if ( $nc =~ m/^$re_op_parts\z/s && $token ne '' ) {
				last; # delimit the token
			}
			
			if ( $$line =~ s/^([\?\*\+\@\!]\()// ) { # extglob patterns
				set_quotmode('?(', $1);
				next;
			}
			
			# If the current character is an unquoted <newline>, the current token shall be delimited.
			if ( $nc =~ m/[\n]/s ) {
				if ( $token eq '' ) {
					shift_char(); # take the <newline>
				}
				last; # delimit the token
			}
			
			# If the current character is an unquoted <blank>, any token containing
			# the previous character is delimited and the current character shall be discarded.
			if ( $nc =~ m/[ \t\r]/s ) {
				if ( $token ne '' ) {
					last; # delimit the token
				}
				$$line =~ s/^([ \t\r]+)//s; # discard the whitespaces
				next;
			}
			
			if ( $nc eq '\\' ) {
				discard_char();
				set_quotmode($nc);
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			if ( $nc eq '=' ) {
				if ( $$line =~ s/^( =\( )//x ) { # array initialization syntax
					set_quotmode($1);
					next;
				}
			}
			
			# If the previous character was part of a word, the current character
			# shall be appended to that word.
			if ( $token ne '' ) {
				shift_char();
				next;
			}
			
			# If the current character is a '#', it and all subsequent characters
			# up to, but excluding, the next <newline> shall be discarded as a comment.
			# The <newline> that ends the line is not considered part of the comment.
			if ( $nc eq '#' ) { # The token is '' due to the previous rule.
				$$line =~ s/^(#[^\n]*)//s; # discard characters up to <newline>
				my $comment = $1;
				if ( $comment =~ /\\$/ ) { # Comment ends with \<newline>
					$self->call_hook($self->YYData->{LINENO}, "S_NEWLINE_IN_COMMENT", $comment);
				}
				next;
			}
			
			# The current character is used as the start of a new word.
			shift_char();
			next;
		} # end of quotmode '' (unescaped)
		
		# Command Substitution
		elsif ( $quotmode eq '$(' ) {
			# If the previous character was used as part of an operator...
			
			if ( $token eq '' || $token =~ m/^$re_op_parts\z/s ) {
				# ... and the current character is not quoted and can be used
				# with the current characters to form an operator,
				# [ treat '((' as two parentheses '(' '(' ]
				if ( ($token.$nc) =~ m/^$re_operators\z/s ) {
					# it shall be used as part of that (operator) token.
					
					# [ Match parentheses ]
					if ( $nc eq '(' ) {
						$par_count++;
						shift_char();
						next;
					}
					elsif ( $nc eq ')' ) {
						if ( $par_count == 0 ) { # This is the closing parenthesis!
							discard_char();
							off_quotmode(')');
							next;
						}
						$par_count--;
						shift_char();
						next;
					}
					
					shift_char();
					next;
				}
				elsif ( $token ne '' ) {
					# If the previous character was used as part of an operator and the current
					# character cannot be used with the current characters to form an operator,
					# the operator containing the previous character shall be delimited.
					
					push @$result, $part; $token = $part = ""; # delimit the token
					next;
				}
			}
			
			# If the current character is not quoted and can be used as the first
			# character of a new operator, the current token (if any) shall be delimited.
			# The current character shall be used as the beginning of the next (operator) token.
			if ( $nc =~ m/^$re_op_parts\z/s && $token ne '' ) {
				push @$result, $part; $token = $part = ""; # delimit the token
				next;
			}
			
			if ( $$line =~ s/^([\?\*\+\@\!]\()// ) { # extglob patterns
				set_quotmode('?(', $1);
				next;
			}
			
			# If the current character is an unquoted <newline>, the current token shall be delimited.
			if ( $nc =~ /[\n]/s ) {
				if ( $token ne '' ) {
					push @$result, $part; $token = $part = ""; # delimit the token
					# no need to do next();
				}
				shift_char();
				push @$result, $part; $token = $part = ""; # delimit the token
				next;
			}
			
			# If the current character is an unquoted <blank>, any token containing
			# the previous character is delimited and the current character shall be discarded.
			if ( $nc =~ /[ \t\r]/s ) {
				if ( $token ne '' ) {
					push @$result, $part; $token = $part = ""; # delimit the token
				}
				$$line =~ s/^([ \t\r]+)//s; # discard the whitespaces
				push @$result, $1;
				next;
			}
			
			if ( $nc eq '\\' ) {
				discard_char();
				set_quotmode($nc);
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			if ( $nc eq '=' ) {
				if ( $$line =~ s/^( =\( )//x ) { # array initialization syntax
					set_quotmode($1);
					next;
				}
			}
			
			# If the previous character was part of a word, the current character
			# shall be appended to that word.
			if ( $token ne '' ) {
				shift_char();
				next;
			}
			
			# If the current character is a '#', it and all subsequent characters
			# up to, but excluding, the next <newline> shall be discarded as a comment.
			# The <newline> that ends the line is not considered part of the comment.
			if ( $nc eq '#' ) { # The token is '' due to the previous rule.
				$$line =~ s/^(#[^\n]*)//s; # discard characters up to <newline>
				my $comment = $1;
				if ( $comment =~ /\\$/ ) { # Comment ends with \<newline>
					$self->call_hook($self->YYData->{LINENO}, "S_NEWLINE_IN_COMMENT", $comment);
				}
				next;
			}
			
			# The current character is used as the start of a new word.
			shift_char();
			next;
		} # end of quotmode '$(' (Command Substitution)
		
		# Backquote Command Substitution
		elsif ( $quotmode eq '`' ) {
			# Within the backquoted style of command substitution,
			# backslash shall retain its literal meaning,
			# except when followed by: '$', '`', or '\'.
			if ( $nc eq '\\' ) {
				if ( $$line =~ /^\\[\$\`\\]/ ) {
					discard_char();
					set_quotmode($nc);
					next;
				}
			}
			
			# The search for the matching backquote shall be satisfied
			# by the first backquote found without a preceding backslash.
			if ( $nc eq '`' ) {
				discard_char();
				off_quotmode($nc);
				next;
			}
			
			# During this search, if a non-escaped backquote is encountered
			# within a shell comment, a here-document, an embedded command
			# substitution of the $(command) form, or a quoted string,
			# undefined results occur.
			# A single-quoted or double-quoted string that begins,
			# but does not end, within the "`...`" sequence produces undefined results.
			
			# The current character is used as the start of a new word.
			shift_char();
			next;
		} # end of quotmode '`' (Backquote Command Substitution)
		
		# Arithmetic Expansion
		elsif ( $quotmode eq '$((' ) {
			# For $((expression)) and ((expression)) the expression is treated
			# as if it were within double quotes, but a double quote inside
			# the parentheses is not treated specially.
			
			if ( $nc eq '\\' ) {
				# [ The backslash is an escape character only when followed by '$' or '`'. ]
				if ( $$line =~ /^\\[\$\`]/ ) {
					discard_char();
					set_quotmode($nc);
					next;
				}
			}
			elsif ( $nc eq '(' ) { # Match parentheses
				$par_count++;
				shift_char();
				next;
			}
			elsif ( $nc eq ')' ) {
				if ( $par_count == 0 ) { # Closing '))' is expected
					if ( $$line =~ s/^\)\)// ) {
						off_quotmode('))');
					} else {
						$self->_Error("Unmatching parantheses in construction \$((...))");
						discard_char();
						off_quotmode(')');
					}
					next;
				}
				$par_count--;
				shift_char();
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			shift_char();
			next;
		} # end of quotmode '$((' (Arithmetic Expansion)
		
		# Alternative Arithmetic Expansion?
		elsif ( $quotmode eq '$[' ) {
			# [ Undocumented arithmetic expansion syntax? ]
			
			if ( $nc eq '\\' ) {
				if ( $$line =~ /^\\[\$\`'"]/ ) {
					discard_char();
					set_quotmode($nc);
					next;
				}
			}
			elsif ( $nc eq ']' ) { # Close
				discard_char();
				off_quotmode($nc);
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			shift_char();
			next;
		} # end of quotmode '$[' (Alternative Arithmetic Expansion?)
		
		# Conditional compound command
		elsif ( $quotmode eq '[[' ) {
			if ( $nc eq '\\' ) {
				discard_char();
				set_quotmode($nc);
				next;
			}
			elsif ( $nc eq '[' ) { # Match parentheses
				$par_count++;
				shift_char();
				next;
			}
			elsif ( $nc eq ']' ) {
				if ( $par_count < 2 && $$line =~ s/^(\]\])// ) {
					off_quotmode($1);
					next;
				}
				$par_count--;
				shift_char();
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			shift_char();
			next;
		} # end of quotmode '[[' (Conditional compound command)
		
		# Extglob pattern
		elsif ( $quotmode eq '?(' ) {
			if ( $nc eq '\\' ) {
				discard_char();
				set_quotmode($nc);
				next;
			}
			elsif ( $nc eq '(' ) { # Match parentheses
				$par_count++;
				shift_char();
				next;
			}
			elsif ( $nc eq ')' ) {
				if ( $par_count ==0 ) {
					discard_char();
					off_quotmode($1);
					next;
				}
				$par_count--;
				shift_char();
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			shift_char();
			next;
		}
		
		# Arithmetic Conditional
		elsif ( $quotmode eq '((' ) {
			# For $((expression)) and ((expression)) the expression is treated
			# as if it were within double quotes, but a double quote inside
			# the parentheses is not treated specially.
			
			if ( $nc eq '\\' ) {
				# The backslash shall retain its special meaning as an 
				# escape character (see Escape Character (Backslash)) only when followed
				# by one of the following characters when considered special:  $   `   "   \
				if ( $$line =~ /^\\[\$\`"'\\]/ ) {
					discard_char();
					set_quotmode($nc);
					next;
				}
			}
			elsif ( $nc eq '(' ) { # Match parentheses
				$par_count++;
				shift_char();
				next;
			}
			elsif ( $nc eq ')' ) {
				if ( $par_count == 0 ) {
					if ( $$line =~ s/^(\)\))// ) {
						off_quotmode($1);
						next;
					} else {
						# This appeared to be ((...) ...), not ((...))
						# Shoud do a bit of magic to undo everything since the first '('
						
						my $prev_token = $stack[-1]{TOKEN};
						$no_exp_hook = 1;
						discard_char();
						off_quotmode(')');
						$token = $prev_token;
						$$line = serialize(pop @$result).$$line; # deparse
						shift_char();
						# delimit the '('
						if ( $quotmode eq '' ) {
							last; # delimit the token
						}
						die; # Should not be reached
					}
				}
				$par_count--;
				shift_char();
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			shift_char();
			next;
		} # end of quotmode '((' (Arithmetic Conditional)
		
		# Parameter Expansion
		elsif ( $quotmode eq '${' ) {
			if ( $nc eq '\\' ) {
				discard_char();
				set_quotmode($nc);
				next;
			}
			
			if ( $nc eq '}' ) {
				discard_char();
				off_quotmode($nc);
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			shift_char();
			next;
		} # end of quotmode '${' (Parameter Expansion)
		
		# Array Initialization
		elsif ( $quotmode eq '=(' ) {
			if ( $nc eq '\\' ) {
				discard_char();
				set_quotmode($nc);
				next;
			}
			
			if ( $nc eq ')' ) {
				discard_char();
				off_quotmode($nc);
				next;
			}
			
			check_exppar()
				and next;
			
			check_qq()
				and next;
			
			shift_char();
			next;
		} # end of quotmode '=(' (Array Initialization)
		
		# Parameter
		elsif ( $quotmode eq '$' ) {
			if ( $token =~ /^\d*\z/ && $nc =~ /\d/ ) { # numeric
				shift_char();
				next;
			}
			if ( $token eq "" && $nc =~ /[@*#?\-\$!0]/ ) { # special parameter
				shift_char();
				next;
			}
			if ( $token eq "" && $nc =~ /[A-Za-z_]/ ) { # a valid first character of a variable name
				shift_char();
				next;
			}
			if ( $token =~ /^[A-Za-z_][A-Za-z_0-9]*/ && $nc =~ /[A-Za-z_0-9]/ ) { # variable name
				shift_char();
				next;
			}
			# If an unquoted '$' is followed by a character that is either not numeric,
			# the name of one of the special parameters (see Special Parameters),
			# a valid first character of a variable name, a left curly brace ( '{' ) or
			# a left parenthesis, the result is unspecified.
			if ( $token eq "" ) {
				die if $nc eq '{'; # Should not happen
				
				my $prev_quotmode = '';
				if ( @stack ) {
					$prev_quotmode = $stack[-1]->{QUOTMODE};
				}
				unless ( $prev_quotmode =~ /['"]/ && $nc eq $prev_quotmode ) {
					$self->call_hook( $self->YYData->{LINENO}, "SDOLLAR", $$line, $prev_quotmode );
				}
			}
			
			off_quotmode('');
			next;
		} # end of quotmode '$' (Parameter)
		
		# Quotes '...'
		elsif ( $quotmode eq "'" ) {
			if ( $nc eq $quotmode ) { # the end of quotation.
				discard_char();
				off_quotmode($nc);
				next;
			}
			
			shift_char();
			next;
		} # end of quotmode "'" (Quotes '...')
		
		# Doublequotes "..."
		elsif ( $quotmode eq '"' ) {
			# Enclosing characters in double-quotes ( "" ) shall preserve the literal value
			# of all characters within the double-quotes, with the exception of the characters
			# dollar sign ($), backquote (`), and backslash (\).
			
			check_exppar()
				and next;
			
			if ( $nc eq '\\') {
				if ( $$line =~ /^\\[\$\`"\\]/ ) {
					discard_char();
					set_quotmode($nc);
					next;
				}
			}
			
			if ( $nc eq $quotmode ) { # the end of quotation.
				discard_char();
				off_quotmode($nc);
				next;
			}
			
			shift_char();
			next;
		} # end of quotmode "'" (Doublequotes "...")
		
		# HEREDOC <<
		elsif ( $quotmode eq '<<' ) {
			
			if ( $nc eq '\\') {
				# ...the backslash in the input behaves as the backslash inside double-quotes
				# (see Double-Quotes). However, the double-quote character ( " ) shall not be
				# treated specially within a here-document.
				if ( $$line =~ /^\\[\$\`\\]/ ) {
					discard_char();
					set_quotmode($nc);
					next;
				}
			}
			
			check_exppar()
				and next;
			
			shift_char();
			next;
		} # end of quotmode "<<" (HEREDOC <<)
		
		die "Unhandled quotmode: $quotmode";
	}
	
	if ( $part ne "" ) {
		push @$result, $part;
		$part = '';
	}
	
	while ( @stack ) {
		unless ( $quotmode eq '\\' || $quotmode eq '$' ) {
			$self->_Error("Unclosed $quotmode : '".limit_len(serialize($result))."'");
		}
		off_quotmode("");
	}
	
	# The token was delimited!
	
	if ( $expect_heredoc ) {
		# We just have read a WORD that is a here-document delimiter.
		# Read the following lines until this delimiter is encountered.
		# Then return the readed text instead the delimiter (that is what expected).
		
		# Quote removal shall be applied to the word to determine the delimiter
		# that is used to find the end of the here-document that begins after the next <newline>.
		my $delimiter = unquote($result);
		# There may be tricks in the definition of the delimiter. Do our best to unquote it.
		# If failed, then $delimiter is undef.
		if ( !defined $delimiter || !$delimiter ) {
			$self->_Error("Failed to unquote HEREDOC delimiter: '".limit_len(serialize($result))."'");
		}
		my $word = "";
		while ( 1 ) {
			my $s = $self->read_line();
			if ( !defined $s ) {
				$self->_Error("EOF, but expected end of HEREDOC ($delimiter)");
				return [""];
			}
			$s =~ s/[\x0d\n]$//; # chomp
			if ( $expect_heredoc == 2 ) {
				# If the redirection symbol is "<<-", all leading <tab>s shall be stripped
				# from input lines and the line containing the trailing delimiter.
				$s =~ s/^\t+//mg;
			}
			last if $s eq $delimiter;
			$word .= $s;
		}
		$expect_heredoc = 0;
		
		# If no characters in word are quoted, all lines of the here-document shall be expanded
		# for parameter expansion, command substitution, and arithmetic expansion.
		if ( $delimiter eq $token ) {
			my $oldmode = $self->YYData->{NO_READLINE};
			$self->YYData->{NO_READLINE} = 1;
			$result = $self->read_token(\$word, '<<'); # parse the HEREDOC text
			$self->YYData->{NO_READLINE} = $oldmode;
			return [$result];
		} else {
			return [[$word]];
		}
	}
	
	return $result;
}

sub is_name {
	my ($word) = @_;
	
	# In the shell command language, a word consisting solely of underscores, digits,
	# and alphabetics from the portable character set.
	# The first character of a name is not a digit.
	if ( $word =~ /^[A-Za-z_][A-Za-z_0-9]*\z/s ) {
		return 1;
	}
	
	return 0;
}

sub is_assignment {
	my ($struct) = @_;
	
	if ( defined $struct->[0] && ref($struct->[0]) eq '' ) {
		
		if ( $struct->[0] =~ m/^\w+(\[[^\]]*\])?(\+)?=/ ) {
			return 1;
		}
		if ( serialize($struct) =~ m/^\w+(\[[^\]]*\])?(\+)?=/ ) {
			return 1;
		}
	}
	return 0;
}

sub is_expected {
	my ($self, $token) = @_;
	
	#print_ref ($self->{GRAMMAR});
	#return 1;	
	
	my @stack = map {$_->[0]} @{$self->{STACK}};
	
	my $mode = "shift";
	my $nodefault = 1;
	my $rule = undef;
	
	#print "is_expected: TOKEN: '$token'";
	
	my $state = $stack[-1];
	
	#print "=================\n";
	
	while ( defined $state ) {
		#print "??[$mode] $state (".(defined $rule?$rule:'').")\n";
		if ( $mode eq "shift" ) {
			#print "is_expected: CHECK ('$state') $mode";
			
			if ( !exists $self->{STATES}[$state] ) {
				#print "is_expected: state ('$state') doesn't exist.\n";
				die "Should not happen";
			}
			
			if ( exists $self->{STATES}[$state]{ACTIONS} ) {
				#print( 5, "is_expected: TERMS: "
				#	.(join " ", keys %{$self->{STATES}[$state]{ACTIONS}}), "\n" );
				
				foreach my $key ( keys %{$self->{STATES}[$state]{ACTIONS}} ) {
					if ( $token eq $key ) { return 1; }
				}
			}
			
			# default
			
			if ( !exists $self->{STATES}[$state]{DEFAULT} ) { last; }
			
			my $rule_num = -$self->{STATES}[$state]{DEFAULT};
			$rule = $self->{GRAMMAR}[$rule_num][1];
			
			#print_ref $self->{GRAMMAR}[$rule_num][2];
			my $shift_num = @{$self->{GRAMMAR}[$rule_num][2]};
			for ( my $i = 0; $i < $shift_num; $i++ ) {
				pop @stack;
			}
			
			if ( !@stack ) { die "Should not happen 3"; }
			$state = $stack[-1];
			
			#print "is_expected: reduced $shift_num";
			$mode = "reduced";
			next;
		}
		if ( $mode eq "reduced" ) {
			#print "is_expected: ('$state') REDUCED with '$rule'";
			
			if ( defined $self->{STATES}[$state]{GOTOS}
				&& defined $self->{STATES}[$state]{GOTOS}{$rule} ) 
			{
				$state = $self->{STATES}[$state]{GOTOS}{$rule};
				$mode = "shift";
				push @stack, $state;
				$nodefault = 0;
				next;
			}
			
			last;
		}
	}
	#print "is_expected: stack end";
	
	return 0;
}

sub __Lexer {
	my ($self) = @_;
	
	my $struct = $self->read_token();
	my $token = serialize($struct);
	
	my $tobj = [
			$self->YYData->{LINENO},
			$struct,
		];
	
	if ( ref($struct->[0]) eq 'ARRAY' ) {
		if ( $struct->[0][0] eq '((' ) {
			return ('DPAR', $tobj);
		}
		return ('WORD', $tobj);
	}
	
	if ( $token eq "" ) {
		return ('', undef);
	}
	
	# 2.10.1 Shell Grammar Lexical Conventions
	
	# A <newline> shall be returned as the token identifier NEWLINE.
	if ( $token eq "\n" ) { return ('NEWLINE', $tobj); }
	
	# If the token is an operator, the token identifier for that operator shall result.
	if ( defined $operators{$token} ) {
		if ( $token eq '<<' ) { # HEREDOC follows
			$expect_heredoc = 1;
		}
		elsif ( $token eq '<<-' ) {
			$expect_heredoc = 2;
		}
		return ($operators{$token}, $tobj); 
	}
	
	# Syntactic tokens
	if ( $self->YYIsterm($token) && !$self->YYIssemantic($token) ) {
		return ($token, $tobj);
	}
	
	# If the string consists solely of digits and the delimiter character is one of
	# '<' or '>', the token identifier IO_NUMBER shall be returned.
	if ( $token =~ /\A\d+\z/s && defined $self->YYData->{LINE} && $self->YYData->{LINE} =~ /^[<>]/ ) {
		if ( $self->is_expected('IO_NUMBER') ) {
			return ('IO_NUMBER', $tobj);
		}
		else {
			# Bash allows syntax like '2>&1>/dev/null'
			$self->call_hook( $self->YYData->{LINENO}, "NOT_IO_NUMBER", $token.$self->YYData->{LINE} );
		}
	}
	
	# Otherwise, the token identifier TOKEN results.
	# Further distinction on TOKEN is context-dependent.
	
	if ( defined $reserved{$token} && $self->is_expected($reserved{$token}) ) {
		return ($reserved{$token}, $tobj);
	}
	
	if ( $self->is_expected('ASSIGNMENT_WORD') && is_assignment($struct) ) {
		$self->call_hook( $self->YYData->{LINENO}, "ASSIGNMENT_WORD", $struct );
		return ('ASSIGNMENT_WORD', $tobj);
	}
	
	return ('WORD', $tobj);
}

# Lexer wrapper
sub _Lexer {
	my ($self) = @_;
	
	my ($type, $token) = __Lexer($self);
	
	if ( $type eq 'WORD' ) {
		$self->call_hook( $token->[0], "EXPANSION", ['', @{$token->[1]},''] );
	}
	
	return ($type, $token);
}

sub _Error {
	my ($self, $msg) = @_;
	
	if ( !defined $msg ) { # Parser's error
		my $token = $self->YYCurval;
		
		my $linenum = $token ? $token->[0] : 0;

		$self->call_hook($linenum, "PARSERERR");
		
		my @expected = $self->YYExpect();
		print "EXPECTED# @expected\n";
		
		#print "Parse error: near '".($token ? serialize($token->[1]) : "")."'";
	} else {
		$self->call_hook($self->YYData->{LINENO}, "MISCERR", $msg);
		
		#print "Error at line ".$self->YYData->{LINENO}.": ".$msg;
	}
}

sub Run {
	my ($self, $filename, $text_ref) = @_;
	
	# Set the input
	$self->YYData->{FILENAME} = $filename;
	$self->YYData->{INPUT} = $$text_ref;
	
	$self->YYParse( yylex => \&_Lexer, yyerror => \&_Error );
}

#-----------------------------------------------------------------------


=for None

=cut


#line 9311 ShParser.pm



1;
