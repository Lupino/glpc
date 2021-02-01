module Lexer
  ( reservedNameApp
  , reservedNameCommand
  , reservedNameTelemetry
  , reservedNameFunction
  , reservedNameLoop
  , reservedNameSetup
  , reservedNameInit
  , reservedNameFlag
  , reservedNameAttr
  , reservedNameMetric
  , reservedNameMonitor
  , braces
  , symbol
  , bool
  , reserved
  , identifier
  , integerString
  , floatString
  , stringLiteral
  , whiteSpace
  , commaSep1
  , colon
  ) where

import           Text.Parsec          (alphaNum, char, letter, (<|>))
import           Text.Parsec.Language (emptyDef)
import           Text.Parsec.String   (Parser)
import qualified Text.Parsec.Token    as Token

-- * Wasp element types

reservedNameApp :: String
reservedNameApp = "app"

reservedNameCommand :: String
reservedNameCommand = "command"

reservedNameTelemetry :: String
reservedNameTelemetry = "telemetry"

reservedNameFunction :: String
reservedNameFunction = "func"

reservedNameLoop :: String
reservedNameLoop = "loop"

reservedNameSetup :: String
reservedNameSetup = "setup"

reservedNameInit :: String
reservedNameInit = "init"

reservedNameFlag :: String
reservedNameFlag = "flag"

reservedNameAttr :: String
reservedNameAttr = "attr"

reservedNameMetric :: String
reservedNameMetric = "metric"

reservedNameMonitor :: String
reservedNameMonitor = "monitor"

-- * Data types.

reservedNameBooleanTrue :: String
reservedNameBooleanTrue = "true"

reservedNameBooleanFalse :: String
reservedNameBooleanFalse = "false"

reservedNames :: [String]
reservedNames =
    -- * Wasp element types
    [ reservedNameApp
    , reservedNameCommand
    , reservedNameTelemetry
    , reservedNameFunction
    , reservedNameLoop
    , reservedNameSetup
    , reservedNameInit
    , reservedNameFlag
    , reservedNameAttr
    , reservedNameMetric
    , reservedNameMonitor
    -- * Data types
    , reservedNameBooleanTrue
    , reservedNameBooleanFalse
    ]

gaspLanguageDef :: Token.LanguageDef ()
gaspLanguageDef = emptyDef
    { Token.commentLine = "//"
    , Token.reservedNames = reservedNames
    , Token.caseSensitive = True
    -- Identifier
    , Token.identStart = letter
    , Token.identLetter = alphaNum <|> char '_'
    }

gaspLexer :: Token.TokenParser ()
gaspLexer = Token.makeTokenParser gaspLanguageDef

reserved :: String -> Parser ()
reserved = Token.reserved gaspLexer

identifier :: Parser String
identifier = Token.identifier gaspLexer

symbol :: String -> Parser String
symbol = Token.symbol gaspLexer

colon :: Parser String
colon = Token.colon gaspLexer

braces :: Parser a -> Parser a
braces = Token.braces gaspLexer

commaSep1 :: Parser a -> Parser [a]
commaSep1 = Token.commaSep1 gaspLexer

whiteSpace :: Parser ()
whiteSpace = Token.whiteSpace gaspLexer

stringLiteral :: Parser String
stringLiteral = Token.stringLiteral gaspLexer

integer :: Parser Integer
integer = Token.integer gaspLexer

naturalOrFloat :: Parser(Either Integer Double)
naturalOrFloat = Token.naturalOrFloat gaspLexer

integerString :: Parser String
integerString = show <$> integer

floatString :: Parser String
floatString = do
  v <- naturalOrFloat
  case v of
    Left vv  -> return $ show vv
    Right vv -> return $ show vv
-- * Parsing boolean values

bool :: Parser Bool
bool = boolTrue <|> boolFalse

boolTrue :: Parser Bool
boolTrue = reserved reservedNameBooleanTrue *> return True

boolFalse :: Parser Bool
boolFalse = reserved reservedNameBooleanFalse *> return False
