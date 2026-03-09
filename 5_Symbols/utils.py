"""Utility functions for quantitative analysis transforms."""

from __future__ import annotations

import numpy as np
import pandas as pd


def compute_returns(series: pd.Series) -> pd.Series:
    """Compute percentage returns for a price series.

    Args:
        series: A pandas Series of prices.

    Returns:
        A pandas Series of period-over-period percentage returns.
    """
    return series.pct_change().dropna()


def compute_rolling_average(series: pd.Series, window: int = 20) -> pd.Series:
    """Compute a simple rolling mean for a series.

    Args:
        series: A pandas Series of numeric values.
        window: Rolling window size (default 20).

    Returns:
        A pandas Series of rolling averages.
    """
    return series.rolling(window=window).mean()


def compute_z_scores(series: pd.Series) -> pd.Series:
    """Compute z-scores (standardized values) for a series.

    Args:
        series: A pandas Series of numeric values.

    Returns:
        A pandas Series of z-scores.
    """
    mean = series.mean()
    std = series.std()
    if std == 0:
        return pd.Series(np.zeros(len(series)), index=series.index)
    return (series - mean) / std


def get_numeric_columns(df: pd.DataFrame) -> list[str]:
    """Return the names of numeric columns in a DataFrame.

    Args:
        df: Input DataFrame.

    Returns:
        List of column names with numeric dtype.
    """
    return df.select_dtypes(include="number").columns.tolist()


def get_sample_data() -> pd.DataFrame:
    """Return a synthetic daily OHLCV-style sample DataFrame.

    Generates 252 trading days of synthetic price data for five
    fictional tickers so the app works without network access or file
    uploads.

    Returns:
        A DataFrame with columns Date, Open, High, Low, Close, Volume
        for each ticker in wide format (multi-level columns flattened
        to ``{field}_{ticker}``).
    """
    np.random.seed(42)
    dates = pd.bdate_range(end=pd.Timestamp.today(), periods=252)
    tickers = ["AAPL", "MSFT", "GOOGL", "AMZN", "NVDA"]
    frames: dict[str, pd.Series] = {}
    for ticker in tickers:
        prices = 100 * np.cumprod(1 + np.random.normal(0.0005, 0.015, len(dates)))
        frames[f"Close_{ticker}"] = pd.Series(prices, index=dates)
    df = pd.DataFrame(frames)
    df.index.name = "Date"
    df = df.reset_index()
    return df


def try_fetch_yfinance(
    tickers: list[str], period: str = "1y"
) -> pd.DataFrame | None:
    """Fetch closing prices from Yahoo Finance via yfinance.

    Args:
        tickers: List of ticker symbols (e.g. ``["AAPL", "MSFT"]``).
        period: Valid yfinance period string such as ``"1y"`` or ``"6mo"``.

    Returns:
        A DataFrame of closing prices with a ``Date`` column, or ``None``
        if yfinance is unavailable or the download fails.
    """
    try:
        import yfinance as yf  # noqa: PLC0415

        raw = yf.download(tickers, period=period, progress=False)
        if raw.empty:
            return None
        close = raw["Close"] if "Close" in raw.columns else raw
        close = close.reset_index()
        close.columns = [str(c) for c in close.columns]
        return close
    except Exception as exc:  # noqa: BLE001
        import warnings

        warnings.warn(f"yfinance fetch failed: {exc}", stacklevel=2)
        return None
