//
//  SOXKeys_BitcoinDE.m
//  BitcoinApp
//
//  Created by Peter Hauke on 21.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "SOXKeys_BitcoinDE.h"

@implementation SOXKeys_BitcoinDE

#pragma mark - Notifications
NSString *const BitcoinDE_Notification_RequestShowAccountInfo   = @"Notification_RequestShowAccountInfo";
NSString *const BitcoinDE_Notification_RequestShowRates         = @"Notification_RequestShowRates";
NSString *const BitcoinDE_Notification_PresentBannerInformationForCurrency = @"Notification_PresentBannerInformationForCurrency";

#pragma mark - Bitcoin flavours
NSString *const BitcoinDE_TradingPair_BitcoinOriginal   = @"btceur";
NSString *const BitcoinDE_TradingPair_BitcoinCash       = @"bcheur";
NSString *const BitcoinDE_TradingPair_Ethereum          = @"etheur";

#pragma mark - BitcoinDE_ExecuteTrade
NSString *const BitcoinDE_ExecuteTrade_OrderID              = @"order_id";
NSString *const BitcoinDE_ExecuteTrade_Type                 = @"type";
NSString *const BitcoinDE_ExecuteTrade_BitcoinAmount        = @"amount";
NSString *const BitcoinDE_ExecuteTrade_IsAutomaticTrade     = @"isAutomaticTrade";
NSString *const BitcoinDE_ExecuteTrade_Price                = @"price";
NSString *const BitcoinDE_ExecuteTrade_AutomaticTradePrice  = @"automaticTradePrice";

#pragma mark - BitcoinDE_ShowAccountInfo
NSString *const BitcoinDE_ShowAccountInfo_MainKey = @"data";
#pragma mark | BTC-Balance
NSString *const BitcoinDE_ShowAccountInfo_Balances                  = @"balances";
NSString *const BitcoinDE_ShowAccountInfo_Balance_total_amount      = @"total_amount";
NSString *const BitcoinDE_ShowAccountInfo_Balance_available_amount  = @"available_amount";
NSString *const BitcoinDE_ShowAccountInfo_Balance_reserved_amount   = @"reserved_amount";

#pragma mark | Fidor-Reservation
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_fidor_reservation   = @"fidor_reservation";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_total_amount        = @"total_amount";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_available_amount    = @"available_amount";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_reserved_at         = @"reserved_at";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_valid_until         = @"valid_until";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_allocation          = @"allocation";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_allocation_percent  = @"percent";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_allocation_max_eur_volume = @"max_eur_volume";
NSString *const BitcoinDE_ShowAccountInfoFidorReservation_allocation_eur_volume_open_orders = @"eur_volume_open_orders";

#pragma mark | Encrypted-Information
NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_encrypted_information   = @"encrypted_information";
NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_bic_short               = @"bic_short";
NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_bic_full                = @"bic_full";
NSString *const BitcoinDE_ShowAccountInfoEncryptedInformation_uid                     = @"uid";

#pragma mark - BitcoinDE_ShowAccountLedger
#pragma mark | Details zur Position
NSString *const BitcoinDE_ShowAccountLedger_Main        = @"account_ledger";
NSString *const BitcoinDE_ShowAccountLedger_Date        = @"date";
NSString *const BitcoinDE_ShowAccountLedger_Type        = @"type";
NSString *const BitcoinDE_ShowAccountLedger_Reference   = @"reference";
NSString *const BitcoinDE_ShowAccountLedger_Cashflow    = @"cashflow";
NSString *const BitcoinDE_ShowAccountLedger_Balance     = @"balance";

#pragma mark |- Tradedetails
NSString *const BitcoinDE_ShowAccountLedger_Trade                   = @"trade";
NSString *const BitcoinDE_ShowAccountLedger_Trade_TradeID           = @"trade_id";
NSString *const BitcoinDE_ShowAccountLedger_Trade_Price             = @"price";
NSString *const BitcoinDE_ShowAccountLedger_Trade_BTC               = @"btc";
NSString *const BitcoinDE_ShowAccountLedger_Trade_BTC_BeforeFee     = @"before_fee";
NSString *const BitcoinDE_ShowAccountLedger_Trade_BTC_AfterFee      = @"after_fee";
NSString *const BitcoinDE_ShowAccountLedger_Trade_Euro              = @"euro";
NSString *const BitcoinDE_ShowAccountLedger_Trade_Euro_BeforeFee    = @"before_fee";
NSString *const BitcoinDE_ShowAccountLedger_Trade_Euro_AfterFee     = @"after_fee";

#pragma mark | Page Details
NSString *const BitcoinDE_ShowAccountLedger_Page            = @"page";
NSString *const BitcoinDE_ShowAccountLedger_Page_Current    = @"current";
NSString *const BitcoinDE_ShowAccountLedger_Page_Last       = @"last";

#pragma mark - BitcoinDE_ShowMyOrders
NSString *const BitcoinDE_ShowMyOrders_MainKey = @"orders";

#pragma mark | Order Details
NSString *const BitcoinDE_ShowMyOrders_OrderID                      = @"order_id";
NSString *const BitcoinDE_ShowMyOrders_Type                         = @"type";
NSString *const BitcoinDE_ShowMyOrders_MaxAmount                    = @"max_amount";
NSString *const BitcoinDE_ShowMyOrders_MinAmount                    = @"min_amount";
NSString *const BitcoinDE_ShowMyOrders_Price                        = @"price";
NSString *const BitcoinDE_ShowMyOrders_MaxVolume                    = @"max_volume";
NSString *const BitcoinDE_ShowMyOrders_MinVolume                    = @"min_volume";
NSString *const BitcoinDE_ShowMyOrders_CreatedAt                    = @"created_at";
NSString *const BitcoinDE_ShowMyOrders_EndDateTime                  = @"end_datetime";
NSString *const BitcoinDE_ShowMyOrders_NewOrderForRemainingAmount   = @"new_order_for_remaining_amount";
NSString *const BitcoinDE_ShowMyOrders_State                        = @"state";

#pragma mark | Order Requirements
NSString *const BitcoinDE_ShowMyOrders_OrderRequirements                = @"order_requirements";
NSString *const BitcoinDE_ShowMyOrders_OrderRequirements_MinTrustLevel  = @"min_trust_level";
NSString *const BitcoinDE_ShowMyOrders_OrderRequirements_OnlyKYCFull    = @"only_kyc_full";
NSString *const BitcoinDE_ShowMyOrders_OrderRequirements_PaymentOption  = @"payment_option";
NSString *const BitcoinDE_ShowMyOrders_OrderRequirements_SeatOfBank     = @"seat_of_bank";

#pragma mark | Page information
NSString *const BitcoinDE_ShowMyOrders_Page         = @"page";
NSString *const BitcoinDE_ShowMyOrders_Page_Current = @"current";
NSString *const BitcoinDE_ShowMyOrders_Page_Last    = @"Last";

#pragma mark - BitcoinDE_ShowMyTrades
#pragma mark | Trades
NSString *const BitcoinDE_ShowMyTrades_Trades_MainKey                          = @"trades";
NSString *const BitcoinDE_ShowMyTrades_TradeID                                 = @"trade_id";
NSString *const BitcoinDE_ShowMyTrades_Type                                    = @"type";
NSString *const BitcoinDE_ShowMyTrades_Amount                                  = @"amount";
NSString *const BitcoinDE_ShowMyTrades_Price                                   = @"price";
NSString *const BitcoinDE_ShowMyTrades_Volume                                  = @"volume";
NSString *const BitcoinDE_ShowMyTrades_FeeEur                                  = @"fee_eur";
NSString *const BitcoinDE_ShowMyTrades_FeeBTC                                  = @"fee_btc";
NSString *const BitcoinDE_ShowMyTrades_NewOrderIDForRemainingAmount            = @"new_order_id_for_remaining_amount";
NSString *const BitcoinDE_ShowMyTrades_State                                   = @"state";
NSString *const BitcoinDE_ShowMyTrades_MyRatingForTradingPartner               = @"my_rating_for_trading_partner";
NSString *const BitcoinDE_ShowMyTrades_CreatedAt                               = @"created_at";
NSString *const BitcoinDE_ShowMyTrades_SuccessfullyFinishedAt                  = @"successfully_finished_at";
NSString *const BitcoinDE_ShowMyTrades_CancelledAt                             = @"cancelled_at";
NSString *const BitcoinDE_ShowMyTrades_PaymentMethod                           = @"payment_method";
NSString *const BitcoinDE_ShowMyTrades_TradingPair                             = @"trading_pair";

NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation               = @"trading_partner_information";
NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation_Username      = @"username";
NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation_IsKYCFull     = @"is_kyc_full";
NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation_TrustLevel    = @"trust_level";
NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation_BankName      = @"bank_name";
NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation_BIC           = @"bic";
NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation_SeatOfBank    = @"seat_of_bank";
NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation_AmountTrades  = @"amount_trades";
NSString *const BitcoinDE_ShowMyTrades_TradingPartnerInformation_Rating        = @"rating";

#pragma mark | Page information
NSString *const BitcoinDE_ShowMyTrades_Page         = @"page";
NSString *const BitcoinDE_ShowMyTrades_Page_Current = @"current";
NSString *const BitcoinDE_ShowMyTrades_Page_Last    = @"last";

#pragma mark - BitcoinDE_ShowOrderbook
NSString *const BitcoinDE_ShowOrderbook_MainKey = @"orders";

#pragma mark | Order
NSString *const BitcoinDE_ShowOrderbook_OrderID                     = @"order_id";
NSString *const BitcoinDE_ShowOrderbook_Type                        = @"type";
NSString *const BitcoinDE_ShowOrderbook_TradingPair                 = @"trading_pair";
NSString *const BitcoinDE_ShowOrderbook_MaxAmount                   = @"max_amount";
NSString *const BitcoinDE_ShowOrderbook_MinAmount                   = @"min_amount";
NSString *const BitcoinDE_ShowOrderbook_Price                       = @"price";
NSString *const BitcoinDE_ShowOrderbook_MaxVolume                   = @"max_volume";
NSString *const BitcoinDE_ShowOrderbook_MinVolume                   = @"min_volume";
NSString *const BitcoinDE_ShowOrderbook_OrderRequirementsFullfilled = @"order_requirements_fullfilled";

#pragma mark | Trading Partner Information
NSString *const BitcoinDE_ShowOrderbook_TradingPartnerInformation               = @"trading_partner_information";
NSString *const BitcoinDE_ShowOrderbook_TradingPartnerInformation_Username      = @"username";
NSString *const BitcoinDE_ShowOrderbook_TradingPartnerInformation_IsKYCFull     = @"is_kyc_full";
NSString *const BitcoinDE_ShowOrderbook_TradingPartnerInformation_TrustLevel    = @"trust_level";
NSString *const BitcoinDE_ShowOrderbook_TradingPartnerInformation_BankName      = @"bank_name";
NSString *const BitcoinDE_ShowOrderbook_TradingPartnerInformation_BIC           = @"bic";
NSString *const BitcoinDE_ShowOrderbook_TradingPartnerInformation_Rating        = @"rating";
NSString *const BitcoinDE_ShowOrderbook_TradingPartnerInformation_AmountTrades  = @"amount_trades";

#pragma mark | Order Requirements
NSString *const BitcoinDE_ShowOrderbook_OrderRequirements                   = @"order_requirements";
NSString *const BitcoinDE_ShowOrderbook_OrderRequirements_MinTrustLevel     = @"min_trust_level";
NSString *const BitcoinDE_ShowOrderbook_OrderRequirements_OnlyKYCFull       = @"only_kyc_full";
NSString *const BitcoinDE_ShowOrderbook_OrderRequirements_SeatOfBank        = @"seat_of_bank";
NSString *const BitcoinDE_ShowOrderbook_OrderRequirements_PaymentOptions    = @"payment_option";

#pragma mark - BitcoinDE_ShowRates
NSString *const BitcoinDE_ShowRates_MainKey = @"rates";
#pragma mark | Rates
NSString *const BitcoinDE_ShowRates_rate_trading_pair = @"trading_pair";
NSString *const BitcoinDE_ShowRates_rate_weighted     = @"rate_weighted";
NSString *const BitcoinDE_ShowRates_rate_weighted_3h  = @"rate_weighted_3h";
NSString *const BitcoinDE_ShowRates_rate_weighted_12h = @"rate_weighted_12h";

#pragma mark - WebSocket 
NSString *const BitcoinDE_WebSocket_AddOrder_MainKey    = @"add_order";
NSString *const BitcoinDE_WebSocket_RemoveOrder_MainKey = @"remove_order";
NSString *const BitcoinDE_WebSocket_UpdateOrder_MainKey = @"refresh_express_option";

NSString *const BitcoinDE_WebSocket_BuyOrderType        = @"offer";
NSString *const BitcoinDE_WebSocket_SellOrderType       = @"order";
NSString *const BitcoinDE_WebSocket_TradingPair         = @"trading_pair";


#pragma mark | Add_Order
NSString *const BitcoinDE_WebSocket_AddOrder_OrderID                = @"order_id";
NSString *const BitcoinDE_WebSocket_AddOrder_SocketObjectID         = @"id";
NSString *const BitcoinDE_WebSocket_AddOrder_OrderType              = @"order_type";
NSString *const BitcoinDE_WebSocket_AddOrder_Amount                 = @"amount";
NSString *const BitcoinDE_WebSocket_AddOrder_MinAmount              = @"min_amount";
NSString *const BitcoinDE_WebSocket_AddOrder_Price                  = @"price";
NSString *const BitcoinDE_WebSocket_AddOrder_MinTustLevel           = @"min_trust_level";
NSString *const BitcoinDE_WebSocket_AddOrder_OnlyKYCFull            = @"only_kyc_full";
NSString *const BitcoinDE_WebSocket_AddOrder_IsKYCFull              = @"is_kyc_full";
NSString *const BitcoinDE_WebSocket_AddOrder_SeatOfBankOfCreator    = @"seat_of_bank_of_creator";
NSString *const BitcoinDE_WebSocket_AddOrder_BICShort               = @"bic_short";
NSString *const BitcoinDE_WebSocket_AddOrder_BICFull                = @"bic_full";
NSString *const BitcoinDE_WebSocket_AddOrder_TradeOfSepaCountry     = @"trade_to_sepa_country";
NSString *const BitcoinDE_WebSocket_AddOrder_PaymentOption          = @"payment_option";

#pragma mark | Remove_Order
NSString *const BitcoinDE_WebSocket_RemoveOrder_OrderID     = @"order_id";
NSString *const BitcoinDE_WebSocket_RemoveOrder_OrderType   = @"order_type";
NSString *const BitcoinDE_WebSocket_RemoveOrder_Amount      = @"amount";
NSString *const BitcoinDE_WebSocket_RemoveOrder_Price       = @"price";

#pragma mark | Update_Order

@end
