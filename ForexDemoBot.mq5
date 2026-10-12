
#property strict
#property version "1.00"

#include <Trade/Trade.mqh>
CTrade trade;

input double Lots = 0.01;
input int FastPeriod = 10;
input int SlowPeriod = 30;
input int StopLossPoints = 300;
input int TakeProfitPoints = 600;

int fastHandle, slowHandle;
datetime lastBar = 0;

int OnInit()
{
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE) !=
      ACCOUNT_TRADE_MODE_DEMO)
      return INIT_FAILED;

   fastHandle = iMA(_Symbol, PERIOD_M15, FastPeriod,
                    0, MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, PERIOD_M15, SlowPeriod,
                    0, MODE_EMA, PRICE_CLOSE);

   if(fastHandle == INVALID_HANDLE ||
      slowHandle == INVALID_HANDLE)
      return INIT_FAILED;

   trade.SetExpertMagicNumber(261012);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
}

void OnTick()
{
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE) !=
      ACCOUNT_TRADE_MODE_DEMO)
      return;

   datetime bar = iTime(_Symbol, PERIOD_M15, 0);
   if(bar == 0 || bar == lastBar)
      return;
   lastBar = bar;

   if(PositionSelect(_Symbol))
      return;

   double fast[3], slow[3];
   if(CopyBuffer(fastHandle, 0, 0, 3, fast) != 3 ||
      CopyBuffer(slowHandle, 0, 0, 3, slow) != 3)
      return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   if(fast[2] <= slow[2] && fast[1] > slow[1])
   {
      double sl = NormalizeDouble(
         ask - StopLossPoints * point, digits);
      double tp = NormalizeDouble(
         ask + TakeProfitPoints * point, digits);
      trade.Buy(Lots, _Symbol, 0, sl, tp, "Demo buy");
   }
   else if(fast[2] >= slow[2] && fast[1] < slow[1])
   {
      double sl = NormalizeDouble(
         bid + StopLossPoints * point, digits);
      double tp = NormalizeDouble(
         bid - TakeProfitPoints * point, digits);
      trade.Sell(Lots, _Symbol, 0, sl, tp, "Demo sell");
   }
}
