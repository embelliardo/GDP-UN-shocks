# GDP-UN-shocks
This project studies the impact of shocks on GDP and unemployment rate

# Scope
This work follows mainly the methodology of Blanchard and Quah (1989) and tries to replicate their results. 
It aims to study the fluctuations in GDP and Unemployment Rate due to two structural shocks that are assumed to affect the economy in
two different ways: the first, identified as *Aggregate Supply shock*, is the only one that affects GDP in the long run; the second, *Aggregate Demand
shock*, has only a short run impact on both the variables of interest.
The model used is SVAR with appropriate long run restrictions.

# Contents 
* `main`: main script to upload data, functions, run the model and output results
* data folder: input data - GDP and UN series
* plots folder: plots of the results

# References 
* BLANCHARD, O.J. & QUAH, D. (1989). The Dynamic Effects of Aggregate Demand and Supply Disturbances, *American Economic Review, American Economic Association*, vol. 79(4), pages 655-673, September.
* data are publicly available at http://research.stlouisfed.org/fred2/
