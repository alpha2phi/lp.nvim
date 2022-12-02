# Literate Programming

## Python Code Snippet

We use the datetime package to get the current time.

```python
from datetime import datetime

print(f"The time now is {datetime.now()} ")
```

```text
The time now is 2022-12-01 12:08:27.923139
```

## Another Python Code Snippet

Using the yfinance library, we can get the stock information.

```python
import yfinance as yf

ticker = yf.Ticker("AAPL")
print(ticker.dividends)
```

```text
Date
1987-05-11    0.000536
1987-08-10    0.000536
1987-11-17    0.000714
1988-02-12    0.000714
1988-05-16    0.000714
                ...
2021-11-05    0.220000
2022-02-04    0.220000
2022-05-06    0.230000
2022-08-05    0.230000
2022-11-04    0.230000
Name: Dividends, Length: 77, dtype: float64
```

## JavaScript Code Snippet

```javascript
function sum(a, b) {
  return a + b;
}
console.log("sum of 2 numbers - ", sum(10, 168));
```

```text
sum of 2 numbers -  178
```
