import { Box, Stack, Tabs } from '@mantine/core';
import { TbArrowBackUp, TbBottle, TbSettings } from 'react-icons/tb';
import { Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import Submit from './Submit';
import Colors from './views/colors';
import General from './views/general';
import Items from './views/items';

const Settings: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();

  return (
    <>
      <Box sx={{ height: '100%', display: 'flex' }}>
        <Tabs
          orientation="vertical"
          color="blue"
          sx={{ height: '100%' }}
          value={location.pathname.substring(10)}
          onTabChange={(value) => navigate(`/settings/${value}`)}
        >
          <Tabs.List>
            <Tabs.Tab value={'back'} onClick={() => navigate('/')} icon={<TbArrowBackUp size={20} />}>
              Blips
            </Tabs.Tab>
            <Tabs.Tab value="general" icon={<TbSettings size={20} />}>
              General
            </Tabs.Tab>

            <Tabs.Tab value="items" icon={<TbBottle size={20} />}>
              Sprite
            </Tabs.Tab>
            <Tabs.Tab value="colors" icon={<TbBottle size={20} />}>
              Color
            </Tabs.Tab>
          </Tabs.List>
        </Tabs>
        <Stack p={16} sx={{ width: '100%' }} justify="space-between">
          <Routes>
            <Route path="/general" element={<General />} />
            <Route path="/items" element={<Items />} />
            <Route path="/colors" element={<Colors />} />
          </Routes>
          <Submit />
        </Stack>
      </Box>
    </>
  );
};

export default Settings;
