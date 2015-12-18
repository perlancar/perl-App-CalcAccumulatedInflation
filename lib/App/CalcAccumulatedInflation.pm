package App::CalcAccumulatedInflation;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{calc_accumulated_inflation} = {
    v => 1.1,
    summary => 'Calculate accumulated inflation over the years',
    description => <<'_',

This routine generates a table of accumulated inflation over a period of several
years. You can either specify a fixed rate for every years (`yearly_rate`), or
specify each year's rates (`rates`).

_
    args => {
        years => {
            schema => ['int*', min=>0],
            default => 10,
        },
        rates => {
            summary => 'Different rates for each year, in percent',
            schema  => ['array*', of=>'float*', min_len=>1],
        },
        yearly_rate => {
            summary => 'A single rate for every year, in percent',
            schema => 'float*',
            cmdline_aliases => {y=>{}},
        },
    },
    args_rels => {
        req_one => ['rates', 'yearly_rate'],
    },
    examples => [
        {
            summary => 'See accumulated 6%/year inflation for 10 years',
            args => {yearly_rate=>6},
        },
        {
            summary => "Indonesia's inflation rate for 2003-2014",
            args => {rates=>[5.16, 6.40, 17.11, # 2003-2005
                             6.60, 6.59, 11.06, 2.78, 6.96, # 2006-2010
                             3.79, 4.30, 8.38, 8.36, # 2011-2014
                         ]},
        },
    ],
    result_naked => 1,
};
sub calc_accumulated_inflation {
    my %args = @_;

    my $index = 1;
    my $year = 0;
    my @res = ({year=>$year, index=>$index});

    if (defined $args{yearly_rate}) {
        while ($year < $args{years}) {
            $year++;
            $index *= 1 + $args{yearly_rate}/100;
            push @res, {
                year  => $year,
                index => sprintf("%.4f", $index),
            };
        }
    } else {
        my $rates = $args{rates};
        while ($year < $#{$rates}) {
            $index *= 1 + $rates->[$year]/100;
            $year++;
            push @res, {
                year  => $year,
                rate  => sprintf("%.2f%%", $rates->[$year]),
                index => sprintf("%.4f", $index),
            };
        }
    }

    \@res;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

See the included script L<calc-accumulated-inflation>.

=cut
