#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Deep;

use lib 'lib';

use_ok("MFST::Skating::Data");

subtest rule5 => sub {
    subtest exampleA => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [10,16,24,31,45,48],
            data => {
                A => [3,6,2,4,1,5],
                B => [3,6,2,4,5,1],
                C => [3,6,5,2,1,4],
                D => [2,6,4,3,1,5],
                E => [3,5,1,4,2,6]
            }
        );
        cmp_deeply($data->compute, {
                '10' => 3,
                '16' => 6,
                '24' => 2,
                '31' => 4,
                '45' => 1,
                '48' => 5
        }, "Places for exA");
    };

    subtest exampleB => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [11,21,32,41,51,61],
            data => {
                A => [1,2,3,4,5,6],
                B => [5,2,3,4,1,6],
                C => [1,5,3,2,4,6],
                D => [1,4,2,3,5,6],
                E => [2,1,3,4,5,6]
            }
        );
        cmp_deeply($data->compute, {
                '11' => 1,
                '21' => 2,
                '32' => 3,
                '41' => 4,
                '51' => 5,
                '61' => 6
        }, "Places for exB");
    };
};

subtest rule6 => sub {
    subtest exampleV => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [12,22,32,42,52,62],
            data => {
                A => [1,3,2,4,5,6],
                B => [1,2,5,3,4,6],
                C => [1,2,5,4,3,6],
                D => [4,1,2,5,3,6],
                E => [4,1,2,3,5,6]
            }
        );
        cmp_deeply($data->compute, {
                '12' => 1,
                '22' => 2,
                '32' => 3,
                '42' => 4,
                '52' => 5,
                '62' => 6
        }, "Places for exV");
    };

    subtest exampleG => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [12,23,34,45,56,67],
            data => {
                A => [3,1,4,6,2,5],
                B => [1,4,2,5,3,6],
                C => [5,1,2,4,3,6],
                D => [3,1,2,6,4,5],
                E => [1,2,3,4,5,6],
                F => [2,1,3,6,5,4],
                G => [3,2,4,5,1,6]
            }
        );
        cmp_deeply($data->compute, {
                '12' => 2,
                '23' => 1,
                '34' => 3,
                '45' => 5,
                '56' => 4,
                '67' => 6
        }, "Places for exG");
    };
};

subtest rule7 => sub {
    subtest exampleD => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [15,26,37,48,59,70],
            data => {
                A => [4,5,6,1,2,3],
                B => [6,5,1,4,2,3],
                C => [6,1,3,2,5,4],
                D => [6,1,3,2,5,4],
                E => [6,1,4,5,2,3]
            }
        );
        cmp_deeply($data->compute, {
                '15' => 6,
                '26' => 1,
                '37' => 4,
                '48' => 2,
                '59' => 3,
                '70' => 5
        }, "Places for exD");
    };

    subtest exampleE => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [13,23,33,43,53,63],
            data => {
                A => [1,2,5,3,4,6],
                B => [1,2,5,3,4,6],
                C => [1,5,2,4,3,6],
                D => [5,1,2,6,3,4],
                E => [5,4,2,1,3,6]
            }
        );
        cmp_deeply($data->compute, {
                '13' => 1,
                '23' => 2,
                '33' => 3,
                '43' => 4,
                '53' => 5,
                '63' => 6
        }, "Places for exE");
    };

    subtest exampleJ => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [10,11,12,13,14,15],
            data => {
                A => [5,3,1,2,4,6],
                B => [3,1,4,2,5,6],
                C => [5,4,2,3,1,6],
                D => [4,3,2,1,5,6],
                E => [6,5,2,4,1,3],
                F => [5,1,3,2,4,6],
                G => [2,1,4,3,6,5]
            }
        );
        cmp_deeply($data->compute, {
                '10' => 5,
                '11' => 3,
                '12' => 2,
                '13' => 1,
                '14' => 4,
                '15' => 6
        }, "Places for exJ");
    };

    subtest exampleZ => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [14,24,34,44,54,64],
            data => {
                A => [2,1,5,3,4,6],
                B => [1,2,6,3,4,5],
                C => [5,2,1,3,4,6],
                D => [1,5,2,3,6,4],
                E => [1,5,2,6,4,3],
            }
        );
        cmp_deeply($data->compute, {
                '14' => 1,
                '24' => 2,
                '34' => 3,
                '44' => 4,
                '54' => 5,
                '64' => 6
        }, "Places for exZ");
    };
};

subtest rule7 => sub {
    subtest exampleI => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [16,17,18,19,20,21],
            data => {
                A => [4,3,2,5,1,6],
                B => [3,2,1,4,5,6],
                C => [5,2,1,3,4,6],
                D => [3,4,5,2,1,6],
                E => [2,1,4,3,6,5],
            }
        );
        cmp_deeply($data->compute, {
                '16' => 3.5,
                '17' => 2,
                '18' => 1,
                '19' => 3.5,
                '20' => 5,
                '21' => 6
        }, "Places for exI");
    };

    subtest exampleK => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [80,81,82,83,84,85,86],
            data => {
                A => [1,2,3,4,5,6,7],
                B => [2,3,4,5,6,7,1],
                C => [3,4,5,6,7,1,2],
                D => [4,5,6,7,1,2,3],
                E => [5,6,7,1,2,3,4],
                G => [6,7,1,2,3,4,5],
                F => [7,1,2,3,4,5,6],
            }
        );
        cmp_deeply($data->compute, {
                '80' => 4,
                '81' => 4,
                '82' => 4,
                '83' => 4,
                '84' => 4,
                '85' => 4,
                '86' => 4
        }, "Places for exK");
    };
};

subtest paradox => sub {
    subtest one => sub {
        my $data = MFST::Skating::Data->new(
            competitors => [1,2,3,4,5,6],
            data => {
                A => [1,3,2,5,4,6],
                B => [4,6,5,2,1,3],
                C => [1,3,2,5,4,6],
                D => [4,6,5,2,1,3],
                E => [1,3,2,5,4,6],
                F => [4,6,5,2,1,3],
                G => [1,3,2,5,4,6],
                H => [4,6,5,2,1,3],
                I => [5,2,6,1,4,3],
            }
        );
        cmp_deeply($data->compute, {
                '1' => 5,
                '2' => 2,
                '3' => 6,
                '4' => 1,
                '5' => 4,
                '6' => 3,
        }, "Places for ONE");
    };
};

done_testing;
