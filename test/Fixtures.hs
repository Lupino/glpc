module Fixtures where

import           Data.Maybe      (fromJust)
import qualified Path            as P
import qualified System.FilePath as FP

import           Gasp

app :: App
app = App
    { appName = "test_app"
    , appKey = "some_key"
    , appToken = "some_token!"
    }

gasp :: Gasp
gasp = fromGaspElems
    [ GaspElementApp app
    ]

systemPathRoot :: P.Path P.Abs P.Dir
systemPathRoot = fromJust $ P.parseAbsDir systemFpRoot

systemFpRoot :: FilePath
systemFpRoot = if FP.pathSeparator == '\\' then "C:\\" else "/"
