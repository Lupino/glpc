module Gasp.Gpio
    ( Gpio(..)
    ) where

import           Data.Aeson (ToJSON (..), object, (.=))

data Gpio = Gpio
    { gpioName    :: !String -- Identifier
    , gpioPin     :: !String
    , gpioLink    :: !String
    , gpioFunc    :: !String
    , gpioEmit    :: !String
    , gpioState   :: !String
    , gpioOpen    :: !String
    , gpioClose   :: !String
    , gpioReverse :: !Bool
    } deriving (Show, Eq)

instance ToJSON Gpio where
    toJSON gpio = object
        [ "name"     .= gpioName gpio
        , "pin"      .= gpioPin  gpio
        , "fn"       .= gpioFunc gpio
        , "link"     .= gpioLink gpio
        , "emit"     .= gpioEmit gpio
        , "state"    .= gpioState gpio
        , "open"     .= gpioOpen gpio
        , "close"    .= gpioClose gpio
        , "reverse"  .= gpioReverse gpio
        , "has_link" .= not (null $ gpioLink gpio)
        , "is_input" .= not (null $ gpioFunc gpio)
        ]
