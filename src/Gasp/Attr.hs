module Gasp.Attr
    ( Attr(..)
    ) where

import           Data.Aeson (ToJSON (..), object, (.=))

data Attr = Attr
    { attrName   :: !String -- Identifier
    , attrAddr   :: !Int
    , attrMax    :: !Double
    , attrMin    :: !Double
    , attrType   :: !String
    , attrDef    :: !Double
    , attrGenSet :: !Bool
    , attrScale  :: !Double
    } deriving (Show, Eq)

instance ToJSON Attr where
    toJSON attr = object
        [ "name"       .= attrName   attr
        , "addr"       .= attrAddr   attr
        , "max"        .= attrMax    attr
        , "min"        .= attrMin    attr
        , "scaled_max" .= (attrMax   attr * attrScale attr)
        , "scaled_min" .= (attrMin   attr * attrScale attr)
        , "scale"      .= attrScale  attr
        , "type"       .= attrType   attr
        , "gen_set"    .= attrGenSet attr
        , "default"    .= (attrDef   attr * attrScale attr)
        ]
