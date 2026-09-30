import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

customers=pd.read_csv('customers.csv',parse_dates=['Customer_Since'])
loans=pd.read_csv('loans.csv',parse_dates=['Loan_Date'])
transactions=pd.read_csv('transactions.csv',parse_dates=['Transaction_Date'])

print(customers.shape,loans.shape,transactions.shape)
print('Missing values:',customers.isna().sum().sum(),loans.isna().sum().sum(),transactions.isna().sum().sum())
print('Duplicates:',customers.duplicated().sum(),loans.duplicated().sum(),transactions.duplicated().sum())

print('Total customers:',customers.Customer_ID.nunique())
print('Total deposits:',round(customers.Account_Balance.sum(),2))
print('Total loans:',round(loans.loc[loans.Loan_Status!='Rejected','Loan_Amount'].sum(),2))
print('Outstanding loans:',round(loans.Outstanding_Amount.sum(),2))
print('Default rate %:',round((loans.Loan_Status=='Defaulted').mean()*100,2))
print('Failed transaction rate %:',round((transactions.Transaction_Status=='Failed').mean()*100,2))

loan_summary=loans.groupby('Loan_Type').agg(
 Loan_Count=('Loan_ID','count'),Total_Loan_Amount=('Loan_Amount','sum'),
 Avg_Interest_Rate=('Interest_Rate','mean'),Outstanding=('Outstanding_Amount','sum')
).sort_values('Total_Loan_Amount',ascending=False)
print(loan_summary)

transactions['YearMonth']=transactions.Transaction_Date.dt.to_period('M')
monthly=transactions[transactions.Transaction_Status=='Success'].groupby('YearMonth')['Amount'].sum().reset_index()
monthly['MoM_Growth_%']=monthly.Amount.pct_change()*100
print(monthly.tail(12))

customers['Customer_Segment']=np.select([
 (customers.Annual_Income>=200000)&(customers.Account_Balance>=200000),
 (customers.Annual_Income>=100000)|(customers.Account_Balance>=100000),
 (customers.Annual_Income>=50000)|(customers.Account_Balance>=50000)],
 ['Premium','High Value','Mass Affluent'],default='Standard')
print(customers.Customer_Segment.value_counts())

loan_summary.Total_Loan_Amount.plot(kind='bar',title='Loan Amount by Type')
plt.tight_layout(); plt.show()
