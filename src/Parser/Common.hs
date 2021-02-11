{-
   Common functions used among Gasp parsers.
-}

module Parser.Common
  ( runGaspParser
  , gaspPropertyStringLiteral
  , gaspElementNameAndClosureContent
  , gaspPropertyBool
  , gaspProperty
  , gaspElementNameAndClosure
  , gaspBlockClosure
  , gaspClosure

  , strip
  ) where

import qualified Data.Text          as T
import           Text.Parsec        (ParseError, anyChar, manyTill, parse, try)
import           Text.Parsec.String (Parser)

import qualified Lexer              as L


-- | Runs given gasp parser on a specified input.
runGaspParser :: Parser a -> String -> Either ParseError a
runGaspParser gaspParser = parse gaspParser sourceName
  where
    -- NOTE(matija): this is used by Parsec only when reporting errors, but we currently
    -- don't provide source name (e.g. .gasp file name) to this method so leaving it empty
    -- for now.
    sourceName = ""

-- TODO(matija): rename to just "gaspElement"?
-- | Parses declaration of a gasp element (e.g. App or Page) and the closure content.
gaspElementNameAndClosureContent
    :: String -- ^ Type of the gasp element (e.g. "app" or "page").
    -> Parser a -- ^ Parser to be used for parsing closure content of the gasp element.
    -> Parser (String, a) -- ^ Name of the element and parsed closure content.
gaspElementNameAndClosureContent elementType closureContent =
    gaspElementNameAndClosure elementType (gaspClosure closureContent)

-- | Parses declaration of a gasp element (e.g. App or Page) and the belonging closure.
gaspElementNameAndClosure
    :: String -- ^ Element type
    -> Parser a -- ^ Closure parser (needs to parse braces as well, not just the content)
    -> Parser (String, a) -- ^ Name of the element and parsed closure content.
gaspElementNameAndClosure elementType closure =
    -- NOTE(matija): It is important to have `try` here because we don't want to consume the
    -- content intended for other parsers.
    -- E.g. if we tried to parse "entity-form" this parser would have been tried first for
    -- "entity" and would consume "entity", so entity-form parser would also fail.
    -- This way when entity parser fails, it will backtrack and allow
    -- entity-form parser to succeed.
    --
    -- TODO(matija): should I push this try higher, to the specific case of entity parser
    -- which is causing the trouble?
    -- This way try will be executed in more cases where it is not neccessary, this
    -- might not be the best for the performance and the clarity of error messages.
    -- On the other hand, it is safer?
    try $ do
    L.reserved elementType
    elementName <- L.identifier
    closureContent <- closure

    return (elementName, closureContent)

-- | Parses gasp property along with the key, "key: value".
gaspProperty :: String -> Parser a -> Parser a
gaspProperty key value = L.symbol key <* L.colon *> value

-- | Parses gasp property which has a string literal for a value.
-- e.g.: title: "my first app"
gaspPropertyStringLiteral :: String -> Parser String
gaspPropertyStringLiteral key = gaspProperty key L.stringLiteral

-- | Parses gasp property which has a bool for a value. E.g.: "onEnter: true".
gaspPropertyBool :: String -> Parser Bool
gaspPropertyBool key = gaspProperty key L.bool

-- | Parses gasp closure, which is {...}. Returns parsed content within the closure.
gaspClosure :: Parser a -> Parser a
gaspClosure = L.braces

-- | Parses named gasp closure, which is do...done. Returns content within the closure.
gaspBlockClosure :: Parser String
gaspBlockClosure = do
    _ <- closureStart
    strip <$> manyTill anyChar (try closureEnd)
  where
      closureStart = L.symbol "do"
      closureEnd = L.symbol "done"


-- | Removes leading and trailing spaces from a string.
strip :: String -> String
strip = T.unpack . T.strip . T.pack
