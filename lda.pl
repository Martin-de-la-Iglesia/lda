# Copyright 2017 Martin de la Iglesia

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use Data::Dumper;

# set input file here, 1 document per line:
open(INPUT, "< input.txt");

open(OUTPUT, "> output.txt");

my @input=<INPUT>;
my @tokens;
my %allocations;
my $doccount;
my $document;
my %document_tokens;
my $faktor_a1;
my $faktor_a2;
my $faktor_b1;
my $faktor_b2;
my $i = 1;
my $n = 0;
my $probability_a;
my $probability_b;
my $token;
my $token_index;
my $tokens_global;
my $topic;
my $topic_a_global;
my $topic_a_local;
my $topic_a_words;
my $topic_b_global;
my $topic_b_local;
my $topic_b_words;
my @topics;

foreach $document(@input) {
	$n++;
	push(@tokens,split(' ',$document));
	foreach $token(split(' ',$document)){
		push(@{$document_tokens{$n}}, $token);
	}
}
$n = 0;

foreach $document(@input) {
	$n++;
	foreach $token(@{$document_tokens{$n}}) {
	
		$token_index = $token.$n;
		
		if (rand() <= 0.5) {
				$topic = 'A';
			}
			else {$topic = 'B'};
		
		$allocations{$token_index} = $topic;		
	}
}
$doccount = $n;
$n = 0;

print OUTPUT "Iteration 1:\n".Dumper(\%allocations);

# set number of iterations here:
while ($i < 500) {
print OUTPUT "\nIteration $i:\n---------------\n";

foreach $document(@input) {
	$n++;
	foreach $token(@{$document_tokens{$n}}) {

		$token_index = $token.$n;
	
		$tokens_global = grep $_ eq $token, @tokens;
		
		$topic_a_local = 0;
		$topic_b_local = 0;
		foreach my $temptoken(@{$document_tokens{$n}}) {
		
			if ($allocations{$temptoken.$n} eq 'A') {
				$topic_a_local++;
			}
			elsif ($allocations{$temptoken.$n} eq 'B') {
				$topic_b_local++;
			}	
		}
			
		@topics = values(%allocations);
			
		$topic_a_global = grep $_ eq 'A', @topics;
		$topic_b_global = grep $_ eq 'B', @topics;
		
		$topic_a_words = 0;
		$topic_b_words = 0;
		my $j = 0;
		while ($j <= $doccount) {
			$j++;
			
			my $temptokenindex = $token.$j;		
			
			if ($allocations{$temptokenindex} eq 'A') {
				$topic_a_words++;
			}
			elsif ($allocations{$temptokenindex} eq 'B') {
				$topic_b_words++;
			}			
		}
			
		if ($allocations{$token_index} eq 'A') {	
			$faktor_a1 = $topic_a_local / ($topic_a_local + $topic_b_local);
			$faktor_a2 = $topic_a_words / $topic_a_global;
			$probability_a = $faktor_a1 * $faktor_a2;
			
			$faktor_b1 = ($topic_b_local + 1) / ($topic_a_local + $topic_b_local);
			$faktor_b2 = ($topic_b_words + 1) / ($topic_b_global + $tokens_global);
			$probability_b = $faktor_b1 * $faktor_b2;
			
			if (rand($probability_a + $probability_b) <= $probability_a) {
				$topic = 'A';
			}
			else {$topic = 'B'};
					
			$allocations{$token_index} = $topic;

		}
		elsif ($allocations{$token_index} eq 'B') {	
			$faktor_a1 = ($topic_a_local + 1) / ($topic_a_local + $topic_b_local);
			$faktor_a2 = ($topic_a_words + 1) / ($topic_a_global + $tokens_global);
			$probability_a = $faktor_a1 * $faktor_a2;
			
			$faktor_b1 = $topic_b_local / ($topic_a_local + $topic_b_local);
			$faktor_b2 = $topic_b_words / $topic_b_global;
			$probability_b = $faktor_b1 * $faktor_b2;
			
			if (rand($probability_a + $probability_b) <= $probability_a) {
				$topic = 'A';
			}
			else {$topic = 'B'};
				
			$allocations{$token_index} = $topic;
			
		}
		
		# re-calculate to percent:
		my $percent_a = $probability_a * (1 / ($probability_a + $probability_b));
		my $percent_b = $probability_b * (1 / ($probability_a + $probability_b));		
		
		print OUTPUT "$token_index Prob. A: ".sprintf("%.2f",$percent_a)." | Prob. B: ".sprintf("%.2f",$percent_b)."\n";
	}
}
$n = 0;

$i++;
}