#!/usr/bin/perl -w

# This script processes the test cases from amath, see
# http://www.wolfgang-ehrhardt.de/amath_functions.html

use strict;

my $dir = $ARGV[0];

my @test_files =
    ('t_sfd1a.pas',
     't_sfd1.pas',
     't_sfd3a.pas',
     't_sfd3b.pas',
     't_sfd3c.pas',
     't_sfd3.pas',
     't_sfd4.pas',
     't_sfd6.pas',
     't_amath1.pas',
    );

my %name_map =
    ('lnbeta' => 'betaln',
     'beta' => 'beta',
     'lngamma' => 'gammaln',
     'gamma' => 'gamma',
     'fac' => 'fact',		# no actual tests
     'dfac' => 'factdouble',
     'pochhammer' => 'pochhammer',
     'binomial' => 'combin',
     'cauchy_cdf' => 'r.pcauchy',
     'cauchy_inv' => 'r.qcauchy',
     'cauchy_pdf' => 'r.dcauchy',
     'chi2_cdf' => 'r.pchisq',
     'chi2_inv' => 'r.qchisq',
     'chi2_pdf' => 'r.dchisq',
     'exp_cdf' => 'r.pexp',
     'exp_inv' => 'r.qexp',
     'exp_pdf' => 'r.dexp',
     'gamma_cdf' => 'r.pgamma',
     'gamma_inv' => 'r.qgamma',
     'gamma_pdf' => 'r.dgamma',
     'laplace_pdf' => 'laplace',
     'logistic_pdf' => 'logistic',
     'lognormal_cdf' => 'r.plnorm',
     'lognormal_inv' => 'r.qlnorm',
     'lognormal_pdf' => 'r.dlnorm',
     'pareto_pdf' => 'pareto',
     'weibull_cdf' => 'r.pweibull',
     'weibull_inv' => 'r.qweibull',
     'weibull_pdf' => 'r.dweibull',
     'binomial_pmf' => 'r.dbinom',
     'binomial_cdf' => 'r.pbinom',
     'poisson_pmf' => 'r.dpois',
     'poisson_cdf' => 'r.ppois',
     'negbinom_pmf' => 'r.dnbinom',
     'negbinom_cdf' => 'r.pnbinom',
     'hypergeo_pmf' => 'r.dhyper',
     'hypergeo_cdf' => 'r.phyper',
     'rayleigh_pdf' => 'rayleigh',
     'normal_cdf' => 'r.pnorm',
     'normal_inv' => 'r.qnorm',
     'normal_pdf' => 'r.dnorm',
     'beta_cdf' => 'r.pbeta',
     'beta_inv' => 'r.qbeta',
     'beta_pdf' => 'r.dbeta',
     't_cdf' => 'r.pt',
     't_inv' => 'r.qt',
     't_pdf' => 'r.dt',
     'f_cdf' => 'r.pf',
     'f_inv' => 'r.qf',
     'f_pdf' => 'r.df',
     'erf' => 'erf',
     'erfc' => 'erfc',
     'bessel_j0' => 'besselj0', # Really named besselj
     'bessel_j1' => 'besselj1', # Really named besselj
     'bessel_jv' => 'besselj',
     'bessel_y0' => 'bessely0', # Really named bessely
     'bessel_y1' => 'bessely1', # Really named bessely
     'bessel_yv' => 'bessely',
     'bessel_i0' => 'besseli0', # Really named besseli
     'bessel_i1' => 'besseli1', # Really named besseli
     'bessel_iv' => 'besseli',
     'bessel_k0' => 'besselk0', # Really named besselk
     'bessel_k1' => 'besselk1', # Really named besselk
     'bessel_kv' => 'besselk',
    );

sub def_expr_handler {
    my ($f,$pa) = @_;
    return "$f(" . join (",", @$pa) . ")";
}

my %expr_handlers =
    ('r.dcauchy' => sub { &reorder_handler ("3,1,2", @_); },
     'r.pcauchy' => sub { &reorder_handler ("3,1,2", @_); },
     'r.qcauchy' => sub { &reorder_handler ("3,1,2", @_); },
     'r.dchisq' => sub { &reorder_handler ("2,1", @_); },
     'r.pchisq' => sub { &reorder_handler ("2,1", @_); },
     'r.qchisq' => sub { &reorder_handler ("2,1", @_); },
     'r.dexp' => sub { my ($f,$pa) = @_; &def_expr_handler ($f,["$pa->[2]-$pa->[0]","1/$pa->[1]"]); },
     'r.pexp' => sub { my ($f,$pa) = @_; &def_expr_handler ($f,["$pa->[2]-$pa->[0]","1/$pa->[1]"]); },
     'r.qexp' => sub { my ($f,$pa) = @_; &def_expr_handler ($f,[$pa->[2],"1/$pa->[1]"]) . "+$pa->[0]"; },
     'r.dgamma' => sub { &reorder_handler ("3,1,2", @_); },
     'r.pgamma' => sub { &reorder_handler ("3,1,2", @_); },
     'r.qgamma' => sub { &reorder_handler ("3,1,2", @_); },
     'laplace' => sub { my ($f,$pa) = @_; &def_expr_handler ($f,["$pa->[2]-$pa->[0]",$pa->[1]]); },
     'logistic' => sub { my ($f,$pa) = @_; &def_expr_handler ($f,["$pa->[2]-$pa->[0]",$pa->[1]]); },
     'r.dlnorm' => sub { &reorder_handler ("3,1,2", @_); },
     'r.plnorm' => sub { &reorder_handler ("3,1,2", @_); },
     'r.qlnorm' => sub { &reorder_handler ("3,1,2", @_); },
     'pareto' => sub { &reorder_handler ("3,2,1", @_); },
     'r.dweibull' => sub { &reorder_handler ("3,1,2", @_); },
     'r.pweibull' => sub { &reorder_handler ("3,1,2", @_); },
     'r.qweibull' => sub { &reorder_handler ("3,1,2", @_); },
     'r.dbinom' => sub { &reorder_handler ("3,2,1", @_); },
     'r.pbinom' => sub { &reorder_handler ("3,2,1", @_); },
     'r.dpois' => sub { &reorder_handler ("2,1", @_); },
     'r.ppois' => sub { &reorder_handler ("2,1", @_); },
     'r.dnbinom' => sub { &reorder_handler ("3,2,1", @_); },
     'r.pnbinom' => sub { &reorder_handler ("3,2,1", @_); },
     'r.dhyper' => sub { &reorder_handler ("4,1,2,3", @_); },
     'r.phyper' => sub { &reorder_handler ("4,1,2,3", @_); },
     'rayleigh' => sub { &reorder_handler ("2,1", @_); },
     'r.dnorm' => sub { &reorder_handler ("3,1,2", @_); },
     'r.pnorm' => sub { &reorder_handler ("3,1,2", @_); },
     'r.qnorm' => sub { &reorder_handler ("3,1,2", @_); },
     'r.dbeta' => sub { &reorder_handler ("3,1,2", @_); },
     'r.pbeta' => sub { &reorder_handler ("3,1,2", @_); },
     'r.qbeta' => sub { &reorder_handler ("3,1,2", @_); },
     'r.dt' => sub { &reorder_handler ("2,1", @_); },
     'r.pt' => sub { &reorder_handler ("2,1", @_); },
     'r.qt' => sub { &reorder_handler ("2,1", @_); },
     'r.df' => sub { &reorder_handler ("3,1,2", @_); },
     'r.pf' => sub { &reorder_handler ("3,1,2", @_); },
     'r.qf' => sub { &reorder_handler ("3,1,2", @_); },
     'besselj0' => sub { my ($f,$pa) = @_; &def_expr_handler ('besselj',[@$pa,0]); },
     'besselj1' => sub { my ($f,$pa) = @_; &def_expr_handler ('besselj',[@$pa,1]); },
     'besselj' => sub { &reorder_handler ("2,1", @_); },
     'bessely0' => sub { my ($f,$pa) = @_; &def_expr_handler ('bessely',[@$pa,0]); },
     'bessely1' => sub { my ($f,$pa) = @_; &def_expr_handler ('bessely',[@$pa,1]); },
     'bessely' => sub { &reorder_handler ("2,1", @_); },
     'besseli0' => sub { my ($f,$pa) = @_; &def_expr_handler ('besseli',[@$pa,0]); },
     'besseli1' => sub { my ($f,$pa) = @_; &def_expr_handler ('besseli',[@$pa,1]); },
     'besseli' => sub { &reorder_handler ("2,1", @_); },
     'besselk0' => sub { my ($f,$pa) = @_; &def_expr_handler ('besselk',[@$pa,0]); },
     'besselk1' => sub { my ($f,$pa) = @_; &def_expr_handler ('besselk',[@$pa,1]); },
     'besselk' => sub { &reorder_handler ("2,1", @_); },
    );

# -----------------------------------------------------------------------------

my $last_func = '';
my $test_row = 1;

sub output_test {
    my ($gfunc,$expr,$res) = @_;

    my $gfunc0 = ($gfunc eq $last_func) ? '' : $gfunc;

    my $N = $test_row++;
    print "\"$gfunc0\",\"=$expr\",\"$res\",\"=IF(B$N=C$N,\"\"\"\",IF(C$N=0,-LOG10(ABS(B$N)),-LOG10(ABS((B$N-C$N)/C$N))))\"\n";

    $last_func = $gfunc;
}

# -----------------------------------------------------------------------------

sub reorder_handler {
    my ($order,$f,$pargs) = @_;

    my @res;
    foreach (split (',',$order)) {
	push @res, $pargs->[$_ - 1];
    }

    return &def_expr_handler ($f,\@res);
}

# -----------------------------------------------------------------------------

foreach my $f (@test_files) {
    my $fn = "$dir/tests/$f";

    my ($afunc,$gfunc);

    my %vars;
    my $expr;

    open (my $src, "<", $fn) or die "$0: Cannot read $fn: $!\n";
    while (<$src>) {
	last if /^implementation\b/;
    }


    while (<$src>) {
	if (/^procedure\s+test_([a-zA-Z0-9_]+)\s*;/) {
	    $afunc = $1;
	    $gfunc = $name_map{$afunc};
	    printf STDERR "Reading tests for $gfunc\n" if $gfunc;
	    %vars = ();
	    next;
	}

	next unless defined $gfunc;

	if (s/^\s*y\s*:=\s*([a-zA-Z0-9_]+)\s*\(([^;{}]+)\)\s*;// &&
	    $1 eq $afunc) {
	    my $argtxt = $2;

	    $argtxt =~ s/\bldexp\s*\(\s*([-+.eE0-9_]+)\s*,\s*([-+]?\d+)\s*\)/ldexp($1;$2)/;
	    my @args = split (',',$argtxt);
	    my $ok = 1;

	    foreach (@args) {
		s/^\s+//;
		s/\s+$//;
		if (m{^[-+*/() .eE0-9]+$}) {
		    $_ = 0 if /^[-+]?[0-9.]+[eE][-+]?\d+$/ && $_ == 0;
		    next;
		} elsif (exists $vars{$_}) {
		    $_ = $vars{$_};
		    next;
		} elsif (/^ldexp\(([-+.eE0-9_]+);([-+]?\d+)\)$/) {
		    $_ = "2^$2";
		    $_ = "$1*$_" unless $1 == 1;
		} elsif (/^1\s*-\s*ldexp\(([-+.eE0-9_]+);([-+]?\d+)\)$/) {
		    $_ = "2^$2";
		    $_ = "$1*$_" unless $1 == 1;
		    $_ = "1-$_";
		} else {
		    print STDERR "XXX:[$_]\n";
		    $ok = 0;
		    last;
		}
	    }
	    next unless $ok;

	    my $h = $expr_handlers{$gfunc} || \&def_expr_handler;
	    $expr = &$h ($gfunc,\@args);
	}

	while (s/^\s*([a-zA-Z0-9]+)\s*:=\s*([-+.eE0-9_]+)\s*;//) {
	    my $var = $1;
	    my $val = $2;
	    $val = 0 if $val =~ /^[-+]?[0-9.]+[eE][-+]?\d+$/ && $val == 0;
	    $vars{$var} = $val;
	}

	if (/^\s*test(rel|abs)\s*/ && exists $vars{'f'} && defined ($expr)) {
	    &output_test ($gfunc, $expr, $vars{'f'});
	    $expr = undef;
	}
    }
}

# -----------------------------------------------------------------------------