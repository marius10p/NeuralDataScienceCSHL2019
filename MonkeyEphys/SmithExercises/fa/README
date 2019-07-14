Matlab code for Factor Analysis

Version 1.01  October 8, 2011

@ 2011 Byron Yu   byronyu@cmu.edu

================
VERSION HISTORY
================

In notes below, + denotes new feature, - denotes bug fix or removal.

Version 1.01 -- October 8, 2011
+ Model comparison can now include a zero latent dimension model,
  which corresponds to an independent Gaussian model.  Added
  indepGaussFit.m and indepGaussEval.m.  Edited crossvalidate_fa.m.

Version 1.00 -- September 18, 2011
+ Added crossvalidate_fa.m


===================
HOW TO GET STARTED
===================

See example.m.

1) Put data in 'X' (data dimensionality x number of data points)

2) To compare latent dimensionalities, do cross-validation:

   dim = crossvalidate_fa(X);

   The latent dimensionalities considered can be specified as an
   optional argument:

   dim = crossvalidate_fa(X, 'zDimList', zDimList);

   where zDimList is a vector containing latent dimensionalities.  By
   default, zDimList = 1:10.

3) Identify the optimal latent dimensionality from the plots.
   Prediction error and LL should give similar answers.

4) The FA parameters for the optimal latent dimensionality can be
   found in dim(i).estParams, where dim(i).zDim is the optimal latent
   dimensionality.

5) To obtain low-dimensional projections, call

   Z = fastfa_estep(X, dim(i).estParams);

   Note that this gives low-d projections of the training data.  For
   low-d projections of test data, replace 'X' with test data.


================================================
WHAT DOES THE WARNING ABOUT PRIVATE NOISE MEAN?
================================================

The private noise variance (or uniqueness, in FA speak) for one or
more data dimensions may be driven to zero.

There are four possible causes:

1) Highly correlated pairs (or groups) of data dimensions

   Solution: Remove offending rows from 'X'

2) Private noise variance floor is set too high.  By default, it is
   set to 0.01 times the raw variance for each data dimension.

   Solution: Specify a smaller 'minVarFrac' using this optional
   argument to fastfa.m

3) The latent dimensionality is too large.  The extra dimensions in
   the latent space may be dedicated to explaining particular data
   dimensions perfectly, thus giving zero private noise for those
   data dimensions.

   Solution: Reduce latent dimensionality 'zDim'

4) You have encountered a Heywood case.  It's an issue with
   maximum-likelihood parameter learning, whereby more likelihood
   can be gained by setting a private noise to 0 than by finding a
   compromise.  This is a corner case of FA that has been known
   since the 1930's.  Various Bayesian FA models have been proposed,
   but here we simply set a minimum private noise variance for each
   data dimension as a percentage of its raw data variance.

   Two possible solutions: 
   a) Do nothing.  The private variance is automatically capped at 
      some minimum non-zero value.
   b) Remove the offending rows from 'X'.

   For more about Heywood cases, see:
 
   "Bayesian Estimation in Unrestricted Factor Analysis: A Treatment
   for Heywood Cases"
   J. K. Martin and R. P. McDonald.
   Psychometrika, 40, 4, 505-17, Dec 1975.

