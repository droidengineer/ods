module statistics;

import std.stdio;
import std.math;
import std.mathspecial;

void main(string [] args)
{
	writeln("gamma(5) = ", gamma(5));
	writeln("gamma(5+1) = ", gamma(5+1));
	writeln("gamma(20) = ", gamma(20));
	writeln("fac(5) = ", fac(5), " =or= factorial(5) = ",factorial(5));
	writeln("pbinom(5,3,.20) = ",pbinom(5,3,.20));
}

/*** factorial
 *
 */
real fac(real x)
{
	auto running = 0x00000001;
	for(auto i=1;i<=x; i++)
	{
		running *= i;	
	}
	return running;
}

/*** odds(double prob_success)
 * The odds of success are the probability of success divided by
 * the probability of failure.
 */
real []  odds(double prob_success)
{
	return (prob_success/(1-prob_success));
}


/*** odds_ratio(prob1, prob2)
 * The odds ratio is the odds of success in one group divided by
 * the odds of success in a second group.
 * table[] is a 2x2 contingency table being tested where 0,1 = row1-1,2 and
 * 2,3 = row2-1,2
 * Returns: an array containing the OR bounded by the 95% confidence interval.
 */
real [] odds_ratio(double prob1, double prob2, real [] table, double z = 1.96)
{
	real [] ret;
	auto or = odds(prob1)/odds(prob2);
	auto se = sqrt(1/table[0]+1/table[1]+1/table[2]+1/table[3]);	
	auto lnor = log(or);
	
	
	ret[0] = exp(lnor - z * se);
	ret[1] = or;
	ret[2] = exp(lnor + z * se);

	return ret;
}

class _distribution_base (T)
{
public:
	this(T [] l) { _members = l; }

	@property bool empty() { return _members.empty; }
	@property int length() { return _members.length; }

	void append(T val) { _members ~= val; }
	void append(T [] list) { _members ~= list; }

	// measurements of central tendency
	@property int sampleSize() { return _members.length; }
	@property real mean() {
		real y = 0;	
		foreach (e in _members)
			y += e;
		return y/_members.length;
	}

	@property real variance() {
		_auto ybar = mean();
		real y = 0;
		foreach (e in _members)
			y += (e - ybar)^^2;
		return (y/(_members.length - 1));
	}
	
	@property real stddev() {
		return sqrt(variance());
	}

	// coefficient of variation
	@property real covar() {
		return ((stddev()/mean())*100);
	}

	@property real median() {
		if (_members.length % 2) { // odd
			return _members[(_members.length+1)/2];
		else
			return ((_members[_members.length/2]+_members[_members.length/2+1])/2);
	}

	real proportion(int n) { return n/_members.length; }

	@property real mode() {
		return 0;
	}

	@property real stderr() {
		return stddev()/sqrt(_members.length);
	}

	// Confidence intervals. Default only does 95% ci.
	@property real[] ci() {
		real[] ret;
		ret[0] = mean() - (2*stderr());
		ret[1] = mean() + (2*stderr());
		return ret;
	}

private:
	T [] _members;	
}

/** The Binomial distribution
 *
 */
class Binomial (T) : _distribution_base!T
{
public:
	this(int n, int x) { _n = n; _x = x; }

	/** "n choose x" probability
 	*/
	real choose()
	{
		return (fac(_n)/(fac(_x)*fac(_n-_x)));
	}

	// Binomial PDF
	/// n choose x with probability p
	real pdf(double p)
	{
		return (choose()*(p^^_x)*(1-p)^^(_n-_x));
	}

	real proportion() { return _x/_n; }

	real proportion_stderr() {
		auto phat = proportion();
		return sqrt((phat*(1-phat))/(_n - 1));
	}

	// confidence intervals for proportions. z=1.96 = 95%
	real [] agresti-coull(double z = 1.96) {
		real[] ret;
		auto pp = (_x+2)/(_n+4);
		ret[0] = (pp - z * sqrt((pp*(1-pp))/(_n + 4)));
		ret[1] = (pp + z * sqrt((pp*(1-pp))/(_n + 4)));
		return ret;
	}

private:
	int _n = 0;
	int _x = 0;

}

class ChiSquare (T) : _distribution_base!T
{
public:
	this(T [][] observed) { _ot = observed_table; }
	this(T [] observed, T [] expected) { _o = observed; _e = expected; }

	// x2 goodness-of-fit test
	real fit() {
		if (_e.empty || _o.empty) return -1;
		real curr = 0;
		for (int i = 0; i < _o.length; i++) {
			curr += ( ((_o[i] - _e[i])^^2)/_e[i] );
		}
		return curr;
	}

	/*** x2 contingency test.
	 * This is the most commonly used test of association between 
	 * two categorical variables.
	 */
	real contingency(bool continuity = false) {
		// First, convert observed counts to their frequencies
		// Prob(cat1 and cat2) = prob(cat1) * prob(cat2)
		auto levels = _ot.length;
		real col_tot[levels];
		real row_tot[2];
		// calculate row and col totals
		for (int i = 0; i < levels; i++) {
			col_tot[i] = _ot[0][i] + _ot[1][i];
			row_tot[0] += _ot[0][i];
			row_tot[1] += _ot[1][i];
		}
		// generate probability frequencies for each cell of table
		// then derive expected frequencies from that.
		auto table_tot = row_tot[0] + row_tot[1];
		T [] [] exp_table;
		for (int i = 0; i < levels; i++) {
			double lvl = col_tot[i]/table_tot;
			double cat1 = row_tot[0]/table_tot;
			double cat2 = row_tot[1]/table_tot;

			exp_table[0][i] = (lvl*cat1)*table_tot;
			exp_table[1][i] = (lvl*cat2)*table_tot;
		}

		// Generate the chi-square statistic
		double running_tot = 0;
		for (int i = 0; i < levels; i++) {
			if (continuity) {
				running_tot += ( (abs(_ot[0][i] - exp_table[0][i])-.5)^^2/exp_table[0][i];
				running_tot += ( (abs(_ot[1][i] - exp_table[1][i])-.5)^^2/exp_table[1][i];
			} else {
				running_tot += ((_ot[0][i] - exp_table[0][i])^^2)/exp_table[0][i];
				running_tot += ((_ot[1][i] - exp_table[1][i])^^2/exp_table[1][i];
			}
		}

		return running_tot;
	}


private:
	T [] _o, _e;
	T [] [] _ot;
}

class Poisson (T) : _distribution_base!T
{
public:
	real probability(int num_events, double mu) {
		return ( ((E^^-mu)*mu^^num_events)/fac(num_events) );
	}

private:

}
