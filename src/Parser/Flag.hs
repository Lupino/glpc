module Parser.Flag
    ( flag
    ) where

import           Text.Parsec.String (Parser)

import           Data.Maybe         (fromMaybe, listToMaybe)
import qualified Gasp.Flag          as Flag
import           Lexer
import           Parser.Common

-- | A type that describes supported flag properties.
data FlagProperty =  Json !Bool | RetVal !Bool deriving (Show, Eq)

-- | Parses supported flag properties, expects format "key1: value1, key2: value2, ..."
flagProperties :: Parser [FlagProperty]
flagProperties = commaSep1 flagPropertyJson

flagPropertyJson :: Parser FlagProperty
flagPropertyJson = Json <$> gaspPropertyBool "json"

getFlagJson :: [FlagProperty] -> Bool
getFlagJson ps = fromMaybe False . listToMaybe $ [t | Json t <- ps]

-- | Top level parser, parses Flag.
flag :: Parser Flag.Flag
flag = do
    (flagName, flagProps) <- gaspElementNameAndClosureContent reservedNameFlag flagProperties

    return Flag.Flag
        { Flag.flagFunc   = flagName
        , Flag.flagJson   = getFlagJson flagProps
        , Flag.flagRetval = False
        }
