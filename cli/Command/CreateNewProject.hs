module Command.CreateNewProject
    ( createNewProject
    ) where

import           Command                (Command, CommandError (..))
import qualified Common
import           Control.Monad.Except   (throwError)
import           Control.Monad.IO.Class (liftIO)
import           Path                   (File, Path, Rel, parseAbsDir, relfile,
                                         toFilePath, (</>))
import           System.Directory       (createDirectory, getCurrentDirectory)
import qualified System.FilePath        as FP
import           Text.Printf            (printf)
import qualified Util.Terminal          as Term


createNewProject :: String -> Command ()
createNewProject projectName = do
    absCwd <- liftIO getCurrentDirectory
    gaspProjectDir <- case parseAbsDir $ absCwd FP.</> projectName of
        Left err -> throwError $ CommandError ("Failed to parse absolute path to gasp project dir: " ++ show err)
        Right sp -> return sp
    liftIO $ do
        createDirectorySP gaspProjectDir
        writeFileSP (gaspProjectDir </> mainGaspFileInGaspProjectDir) mainGaspFileContent
        writeFileSP (gaspProjectDir </> gitignoreFileInGaspProjectDir) gitignoreFileContent
        writeFileSP (gaspProjectDir </> Common.buildGaspRootFileInGaspProjectDir)
            "File marking the root of Gasp project."

    liftIO $ do
        putStrLn $ Term.applyStyles [Term.Green] $ "Created new Gasp project in ./" ++ projectName ++ " directory!"
        putStrLn $ "Move into created directory and type '"
            ++ Term.applyStyles [Term.Bold] "gasp compile"
            ++ "' to compile the app."

  where
      mainGaspFileInGaspProjectDir :: Path Rel File
      mainGaspFileInGaspProjectDir = [relfile|main.gasp|]
      mainGaspFileContent = unlines
          [ "app %s {" `printf` projectName
          , "  key: \"1234567890abcdef\","
          , "  token: \"1234567890abcdef\", // commit when you use an random token"
          , "  addr: \"00000000\","
          , "  start_addr: 0,"
          , "  ctrl_mode: false"
          , "}"
          , ""
          , "GL_SERIAL = Serial"
          , "DEBUG_SERIAL = Serial"
          , "METRIC_DELAY_MS = attr_delay"
          , "// PING_FAILED_CB = noop"
          , "// AUTH_DELAY_MS = 1000"
          , "// PONG_DELAY_MS = 6000"
          , "// PING_DELAY_MS = 300000"
          , "// PING_FAILED_CB = noop"
          , "// MAX_PING_FAILED = 10"
          , "// MAX_GL_PAYLOAD_LENGTH = {= max_gl_len =}"
          , "// MAX_BUFFER_LENGTH = {= max_buf_len =}"
          , "// MAX_NUM_TOKENS = 10"
          , "// MAX_REQUEST_VALUE_LENGTH = {= max_req_len =}"
          , "// MAX_TMPL_LENGTH = {= max_tpl_len =}"
          , "// METRIC_DELAY_MS = 1800000"
          , "// DEBOUNCE_DELAY_MS = 50"
          , ""
          , "setup {"
          , "    GL_SERIAL.begin(115200);"
          , "    while (!GL_SERIAL) {;}"
          , "}"
          , ""
          , "attr delay {"
          , "  type: unsigned long,"
          , "  default: 1800,"
          , "  min: 60,"
          , "  max: 86400,"
          , "  scale: 1000"
          , "}"
          , ""
          , "metric temperature {"
          , "  type: float,"
          , "  max: 100,"
          , "  min: 0,"
          , "  threshold: 1,"
          , "  prec: 2"
          , "}"
          , ""
          , "func read_%s {" `printf` projectName
          , "    metric_temperature += 0.1;"
          , "    if (metric_temperature > 100) {"
          , "         metric_temperature = 0;"
          , "    }"
          , "}"
          , ""
          , "every read_%s 6000" `printf` projectName
          , ""
          , "attr relay_state {"
          , "  type: uint8_t,"
          , "  default: 0,"
          , "  min: 0,"
          , "  max: 1,"
          , "  gen_set: false,"
          , "  keep: false"
          , "}"
          , ""
          , "func try_set_attr_relay_state {"
          , "    if (attr_relay_mode == 1) {"
          , "        return set_attr_relay_state(json, tokens, num_tokens, retval);"
          , "    }"
          , "    return false;"
          , "}"
          , ""
          , "command set_relay_state {"
          , "  fn: try_set_attr_relay_state,"
          , "  error: \"only relay_mode is 1 can set this value\","
          , "  docs: {"
          , "    name: \"Edit attribute relay_state\","
          , "    command: {"
          , "      docs: ["
          , "        - data is between [0, 1]"
          ,"       ],"
          , "      payload: {"
          , "        method: set_relay_state,"
          , "        data: 0"
          , "      }"
          , "    },"
          , "    return: {"
          , "      docs: ["
          , "         - relay_state is between [0, 1]"
          ,"       ],"
          , "      payload: {"
          , "        relay_state: 0"
          , "      }"
          , "    },"
          , "    error: {"
          , "      payload: {"
          , "        err data must between: [0, 1]"
          , "      }"
          , "    }"
          , "  }"
          , "}"
          , ""
          , "// relay_mode 1 manual mode"
          , "//            0 auto mode"
          , "attr relay_mode {"
          , "  type: uint8_t,"
          , "  default: 0,"
          , "  min: 0,"
          , "  max: 1"
          , "}"
          , ""
          , "func try_toggle_gpio_relay {"
          , "    if (attr_relay_mode == 1) {"
          , "        toggle_gpio_relay();"
          , "    }"
          , "}"
          , ""
          , "gpio relay_mode LED_BUILTIN -> link relay_mode"
          , "gpio relay 12 -> link relay_state"
          , "gpio btn0 11 HIGH -> click try_toggle_gpio_relay"
          , "gpio btn1 10 HIGH -> click toggle_gpio_relay_mode"
          , ""
          , "attr high_temperature {"
          , "  type: float,"
          , "  default: 30,"
          , "  min: 0,"
          , "  max: 100"
          , "}"
          , ""
          , "attr low_temperature {"
          , "  type: float,"
          , "  default: 20,"
          , "  min: 0,"
          , "  max: 100"
          , "}"
          , ""
          , "attr open_delay {"
          , "  type: unsigned long,"
          , "  default: 5,"
          , "  min: 0,"
          , "  max: 3600,"
          , "  scale: 1000"
          , "}"
          , ""
          , "attr close_delay {"
          , "  type: unsigned long,"
          , "  default: 5,"
          , "  min: 0,"
          , "  max: 3600,"
          , "  scale: 1000"
          , "}"
          , "rule metric_temperature < attr_high_temperature && metric_temperature > attr_low_temperature"
          , "  do later attr_open_delay open_gpio_relay"
          , "  else later attr_close_delay close_gpio_relay"
          , "  on attr_relay_mode == 0"
          , ""
          ]

      gitignoreFileInGaspProjectDir :: Path Rel File
      gitignoreFileInGaspProjectDir = [relfile|.gitignore|]
      gitignoreFileContent = unlines
          [ "/build/"
          ]

      writeFileSP = writeFile . toFilePath
      createDirectorySP = createDirectory . toFilePath
