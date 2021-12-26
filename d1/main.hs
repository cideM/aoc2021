{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.Void (Void)
import qualified Text.Megaparsec as M
import qualified Text.Megaparsec.Char as M
import qualified Text.Megaparsec.Char.Lexer as L

type Parser = M.Parsec Void Text

parser :: Parser [Integer]
parser = L.decimal `M.endBy` M.newline

parse :: Text -> Either Text [Integer]
parse input = case M.parse parser "" input of
  Left bundle -> Left $ T.pack $ M.errorBundlePretty bundle
  Right xs -> return xs

countIncreases :: [Integer] -> Int
countIncreases nums = sum $ zipWith (\a b -> if b > a then 1 else 0) nums (tail nums)

solve :: [Integer] -> Text
solve nums =
  let windowSums = zipWith3 (\a b c -> a + b + c) nums (tail nums) (tail $ tail nums)
   in T.intercalate "," $ map (T.pack . show . countIncreases) [nums, windowSums]

main :: IO ()
main = TIO.interact (either id solve . parse)
