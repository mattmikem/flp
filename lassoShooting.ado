	// lassoShooting.ado -- version 12, CBH 2012.09.25

capture prog drop lassoShooting
program lassoShooting , rclass 

	version 12

	syntax varlist(numeric min=2) [if] [in] [, Lambda(real 0) VERbose(integer 2) CONtrols(varlist numeric min=1) LASIter(real 100) LTol(real 1e-5) MAXIter(integer 10000) HETero(integer 1) TOLUps(real 1e-4) TOLZero(real 1e-4) FDisplay(real 1)]

// Record which observations have non-missing values
	marksample touse
	markout `touse' `controls'

// Remove collinear variables
	local RealY : word 1 of `varlist'
	local RealX : list varlist - RealY
//	_rmcollright  `controls' `RealX' if `touse'
//	local dropped `r(dropped)' 
//	local RealX : list RealX - dropped	
	local newvarlist : list RealY | RealX
	
	local rvarlist

// Partial out controls, constant
	foreach x of local newvarlist {
		quietly regress `x' `controls' if `touse'
		tempvar r`x'
		quietly predict `r`x'' if e(sample), r
		local rvarlist : list rvarlist | r`x'
	}
	
// Define outcome (y) and controls to be selected over (xS)
	local y : word 1 of `rvarlist'
	local xS : list rvarlist - y
		
// Define parameters for LASSO
	local p : word count `xS'
	quietly summarize `touse'
	local nUse = r(sum)
	
	if `lambda' == 0 {
		local mylam = 2.2*sqrt(2*`nUse'*log(2*`p'/(.1/log(`nUse'))))
	}
	else {
		local mylam = `lambda'
	}

	matrix define bL = .
	matrix define bPL = .
	local sel
	
	mata: data = MakeData("`y'","`xS'","`RealX'","`touse'")
	mata: OUT = RunLasso(data,`mylam',`verbose',`ltol',`maxiter',`tolzero',`hetero',`lasiter',`tolups')
	mata: ReturnResults(OUT,`fdisplay')
		
	return matrix betaL = bL
	return matrix betaPL = bPL
	return local selected `sel' 
	
end	


version 12
mata

struct dataStruct {
	real colvector y
	real matrix Xs
	real colvector v
	string colvector nameXs 
	string colvector RealNameXs
	}

struct outputStruct {
	real colvector betaPL
	real colvector beta
	string colvector nameXSel
	string colvector RealNameXSel
	real colvector betaAll
	real colvector index
	}
	
struct dataStruct scalar MakeData(string scalar nameY , string scalar nameX , string scalar RealX , string scalar touse)
{
	struct dataStruct scalar t
	
	t.y = st_data(.,nameY,touse)
	t.Xs = st_data(.,nameX,touse)
	t.nameXs = tokens(nameX)
	t.RealNameXs = tokens(RealX)

	return(t)
}

real rowvector MakeLassoWeights(real colvector v , real matrix XX , real scalar hetero )
{
	real rowvector Ups
	
	nObs = rows(v)
	
	if (hetero == 1) {
		St = XX:*(v*J(1,cols(XX),1))
		Ups = sqrt(colsum((St):^2)/nObs)
	}
	else {
		Ups = sqrt(colsum(XX:^2)/nObs)*sqrt(colsum(v:^2)/nObs)
	}
	
	return(Ups)
}


struct outputStruct scalar RunLasso(struct dataStruct scalar data , real scalar lambda , real scalar verbose , real scalar optTol , real scalar maxIter , real scalar zeroTol , real scalar hetero , real scalar lasIter , real scalar UpsTol )
{
	struct outputStruct scalar betas
	X = data.Xs
	y = data.y
	p = cols(X)
	n = rows(X)
	
	Ups = MakeLassoWeights(y , X , hetero)
	
	lambda0 = .5*lambda
	betas = DoLasso(data , Ups , lambda0 , verbose , optTol , maxIter , zeroTol)
	v = y - select(X,betas.index')*betas.betaPL
	
	oldUps = Ups 
	Ups = MakeLassoWeights(v , X , hetero)
	UpsNorm = sqrt(rowsum((Ups-oldUps):^2))
	
	iter = 1
	
	while ((iter < lasIter) & (UpsNorm > UpsTol))
	{
		betas = DoLasso(data , Ups , lambda , verbose , optTol , maxIter , zeroTol)
		v = y - select(X,betas.index')*betas.betaPL
	
		oldUps = Ups 
		Ups = MakeLassoWeights(v , X , hetero)
		UpsNorm = sqrt(rowsum((Ups-oldUps):^2))
	
		iter = iter + 1
	}
	
	return(betas)
}
		
	
struct outputStruct scalar DoLasso(struct dataStruct scalar data , real rowvector Ups , real scalar lambda , real scalar verbose , real scalar optTol , real scalar maxIter , real scalar zeroTol)
{
	struct outputStruct scalar t

	X = data.Xs
	y = data.y
	p = cols(X)
	n = rows(X)
	
	XX = cross(X,X)
	Xy = cross(X,y)

	beta=lusolve(XX+lambda*I(p),Xy)
	if (verbose==2){
		w_old = beta
		printf("%8s %8s %10s %14s %14s\n","iter","shoots","n(w)","n(step)","f(w)")
		k=1
		wp = beta
		}

	m=0
	XX2=XX*2
	Xy2=Xy*2

	while (m < maxIter)
	{
		beta_old = beta
		for (j = 1;j<=p;j++)
		{
			S0 = colsum(XX2[j,.]*beta) - XX2[j,j]*beta[j] - Xy2[j]
			if (S0 > lambda*Ups[1,j])
			{
				beta[j,1] = (lambda*Ups[1,j] - S0)/XX2[j,j]
			}
			else if (S0 < -lambda*Ups[1,j])	
       		{
           		beta[j,1] = (-lambda*Ups[1,j] - S0)/XX2[j,j]
           	}
       		else 
			{
       			beta[j,1] = 0
           	}
        }
            
       	m++

		if (verbose==2)
			{
				printf("%8.0g %8.0g %14.8e %14.8e %14.8e\n",m,m*p,colsum(abs(beta)),colsum(abs(beta-w_old)),colsum((X*beta-y):^2)+lambda*colsum(abs(beta)))
				w_old = beta
				k=k+1
				wp =(wp, beta)
			}
    
		if (colsum(abs(beta-beta_old))<optTol) break
	}
	
	if (verbose)
	{
		printf("Number of iterations: %g\nTotal Shoots: %g\n",m,m*p)
	}

	t.betaAll = beta
	k1 = rows(beta)
	k2 = cols(beta)
	
	t.index = abs(beta) :> zeroTol
	k1 = rows(t.index)
	k2 = cols(t.index)

	t.beta = select(beta,t.index)
	k1 = rows(t.beta)
	k2 = cols(t.beta)
	
	SelX = select(X,t.index')
	
	SelXX = cross(SelX,SelX)
	SelXy = cross(SelX,y)
	betaPL = svsolve(SelXX,SelXy)

	t.betaPL = betaPL
	k1 = rows(betaPL)
	k2 = cols(betaPL)

	t.nameXSel = select(data.nameXs',t.index)
	t.RealNameXSel = select(data.RealNameXs',t.index)
	
	return(t)
}

void ReturnResults(struct outputStruct scalar t, real scalar verbose)
{
	s = rows(t.RealNameXSel)
	Names = t.RealNameXSel
	bLasso = t.beta
	bPostLasso = t.betaPL

	if (verbose == 1)
	{
		if (s > 0)
		{
			printf("{txt}%18s{c |} {space 3} {txt}%10s {space 3} {txt}%10s\n","Selected","LASSO","Post-LASSO")
			printf("{hline 18}{c +}{hline 32}\n")
			
			for (j = 1;j<=s;j++)
			{
				printf("{txt}%18s{c |} {space 3} {res}%10.0g {space 3} {res}%10.0g\n",Names[j,1],bLasso[j,1],bPostLasso[j,1])
			}
		}
		else
		{
			printf("No variables selected.\n")
		}
	}
	
	st_rclear() 
	if (s > 0) {
		st_matrix("bL",bLasso)
		st_matrix("bPL",bPostLasso)
		st_local("sel",invtokens(Names'))
	}
//	else {
//		st_matrix("bL",.)
//		st_matrix("bPL",.)
//		st_local("sel","hi there")
//	}
		
}

end
