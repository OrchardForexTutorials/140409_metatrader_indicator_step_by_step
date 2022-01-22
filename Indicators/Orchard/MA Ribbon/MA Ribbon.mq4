/***********
	MA Ribbon.mq4
	Copyright 2014-2016, Novateq Pty Ltd
	https://orchardforex.com

	Version History
	===============
	1.00		Original version
	
	1.01		Minor code updates before releasing for download
				These should not affect the indicator at all and have been made only
				to keep the code tidy
	1.02     Minor adjustments for re-release under Orchard Forex label
				
***********/

#property copyright "Copyright 2014-2018, Novateq Pty Ltd"
#property link      "https://orchardforex.com"
#property version   "1.02"
#property strict
#property indicator_chart_window

#property indicator_buffers 4

input    int            SignalMAPeriod    =  5;				// Signal period
input    int            FastMAPeriod      =  13;			// Fast period
input    int            SlowMAPeriod      =  34;			// Slow period
input    ENUM_MA_METHOD MAMethod          =  MODE_EMA;	// MA Mode

double   BufferUp[];
double   BufferDown[];

double   BufferFast[];
double   BufferSlow[];

#define  UpIndicator    0
#define  DownIndicator  2
#define  FastIndicator  3
#define  SlowIndicator  1

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

//--- indicator buffers mapping

   SetIndexStyle(UpIndicator,DRAW_HISTOGRAM, STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(UpIndicator, BufferUp);
   SetIndexEmptyValue(UpIndicator,0.0);

   SetIndexStyle(SlowIndicator,DRAW_LINE,STYLE_SOLID, 1, clrGreen);
   SetIndexBuffer(SlowIndicator,BufferSlow);
   SetIndexLabel(SlowIndicator,"Slow");

   SetIndexStyle(DownIndicator,DRAW_HISTOGRAM, STYLE_SOLID, 1, clrFireBrick);
   SetIndexBuffer(DownIndicator, BufferDown);
   SetIndexEmptyValue(DownIndicator,0.0);

   SetIndexStyle(FastIndicator,DRAW_LINE,STYLE_SOLID, 1, clrFireBrick);
   SetIndexBuffer(FastIndicator,BufferFast);
   SetIndexLabel(FastIndicator,"Fast");


   return(INIT_SUCCEEDED);

}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   int      limit;
   double   signalMa,
            fastMa,
            slowMa;
            
   if(rates_total<=SlowMAPeriod)
      return(0);

   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
      
   for(int i=limit-1; i>=0; i--) // alternative    for(i=0; i<limit; i++)
   {
      signalMa=iMA(Symbol(), Period(), SignalMAPeriod, 0, MAMethod, PRICE_CLOSE, i);
      fastMa=iMA(Symbol(), Period(), FastMAPeriod, 0, MAMethod, PRICE_CLOSE, i);
      slowMa=iMA(Symbol(), Period(), SlowMAPeriod, 0, MAMethod, PRICE_CLOSE, i);
      


      if (signalMa>fastMa && fastMa>slowMa) // trending up
      {
         BufferFast[i]=fastMa;
         BufferSlow[i]=slowMa;

         BufferUp[i]=fastMa;
      }
      else if (signalMa<fastMa && fastMa<slowMa) // trending down
      {
         BufferFast[i]=fastMa;
         BufferSlow[i]=slowMa;

         BufferDown[i]=slowMa;
      }
      // If none of the above the trend is not confirmed
   }


//--- return value of prev_calculated for next call
   return(rates_total);

}
//+------------------------------------------------------------------+
